# -*- codeing = utf-8 -*-
# @Time : 2022/4/21 9:51
# @Author : zhang
# @File : WeiboSpider.py
# @Software : PyCharm
#引入包zzz
import urllib.parse
from urllib.parse import urlencode
import requests
import json
import time
from datetime import datetime
from pyquery import PyQuery as pq
import xlwt   #进行excel操作
#自定义区域
readjsonFile=json.load(open('config.json', 'r', encoding="utf-8"))
savepath = readjsonFile.get('savepath')     #可以自定义设计最终excel的路径
search =readjsonFile.get('search')                 #可以自定义设计查询什么内容
#设置起始时间
dateStart=readjsonFile.get('dateStart')    #日期格式必须是：形如：2022-4-21
dateEnd=readjsonFile.get('dateEnd')
urlsearch=urllib.parse.quote('=1&q='+search)     #进行url编码
m_referer='https://m.weibo.cn/search?containerid=231583'   #微博搜索来源界面
base_url = 'https://m.weibo.cn/api/container/getIndex?'     #微博接口
#host用于指定internet主机和端口号，http1.1必须包含，不然系统返回400，
headers = {                 #封装请求头  让网站识别自己是浏览器
    'Referer': m_referer+urlsearch,             #告诉服务器自己是哪里来的  从那个页面来的   来路
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36 Edg/80.0.361.111',    #包含操作系统和浏览器信息
    'Host':'m.weibo.cn',                #请求服务器的域名和端口号
    'X-Requested-With':'XMLHttpRequest'             #代表是ajax请求
}
sign=0      #标志是否找到了实时微博以开始
Pqove=0     #标志位  表示是否读取文件结束
#获取网页的json（这个是获取搜索之后网页的json数据的函数）
def get_page(page):
    para={
        'containerid':m_referer[m_referer.find('100103'):]+urlsearch,
        'page':page
    }
    url = base_url+urlencode(para)                  #进行url编码添加到地址结尾  连带页数
    try:
        response = requests.get(url, headers=headers)       #request请求  地址和携带请求头
        if response.status_code == 200:
            return response.json()                              #以json格式返回数据
    except requests.ConnectionError as e:
        print("Error:",e.args)
#获取全文网页的json（这个是获取需要对全文获取的网页的json数据的函数）
def get_txt_page(containerid,referer):
    base_urlx = 'https://m.weibo.cn/statuses/show?'     #相较于获取搜索结果的url不通
    txtheaders = {
        'Referer': referer,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36 Edg/80.0.361.111',
        'Host': 'm.weibo.cn',
        'X-Requested-With': 'XMLHttpRequest'
    }
    para = {
        'id': containerid,    #只需要一个参数  且参数名为id
    }
    url = base_urlx + urlencode(para)  # 进行url编码添加到地址结尾  连带页数
    try:
        response = requests.get(url, headers=headers)  # request请求  地址和携带请求头
        if response.status_code == 200:
            return response.json()  # 以json格式返回数据
    except requests.ConnectionError as e:
        print("Error:", e.args)
#分析JSON格式的数据，抓取目标信息
def parse_json(data):
    global sign                         #sign是用来标记是否有过title   在格式中从实时微博进行爬取  找到实时微博title之后开始爬取   之后不用进行判断title而用sign来判断
    if data:
        items = data.get('data').get('cards')
        for item1 in items:
            item=item1.get("title")
            if(item!=None or sign==1):       #分析数据发现只有实时微博开始时有一个title  所以可以进行判断是否有title并从title开始爬取
                item2=item1.get("card_group")
                # print(item2)
                # print(len(item2))
                for card in item2:
                    if card.get("mblog")!=None:             #如果没有mblog  那么就结束本次循环不尽兴数据爬取   如果有就进行爬取（因为会有一些数据中不包含mblog代表其并不是所需的数据）
                        sign=1
                        itemc=card.get("mblog")
                        weibo = {}
                        # 抓取信息
                        scheme=str(card.get("scheme"))              #获取具体博文链接（可以访问具体博文数据）
                        txtwb=pq(itemc.get('text')).text()          #获取微博博文
                        if  txtwb.find("全文")+2==len(txtwb):         #利用微博博文进行判断是否结尾有“全文二字”
                            datatxt = get_txt_page(scheme[scheme.find('mblogid=')+8:scheme.find('mblogid=')+17],scheme)  # 如果有全文那么需要进入其中再次进行爬取全文数据，首先切割链接获取mblogid，scheme对应的是Referer的链接信息
                            txtitem=pq(datatxt.get('data').get('text')).text()
                            weibo['text'] = pq(datatxt.get('data').get('text')).text()          #用pyquery去处理得到的数据
                        else:
                            weibo['text'] = pq(itemc.get('text')).text()        #不需要对全文做处理直接获取text
                        weibo['date'] = str(datetime.strptime(pq(itemc.get('created_at')).text(), '%a %b %d %H:%M:%S +0800 %Y'))#日期   #修改日期格式   默认微博日期格式是带时区的GMT的格式
                        weibo['attitudes'] = itemc.get('attitudes_count')  # 点赞次数
                        weibo['comments'] = itemc.get('comments_count')  # 评论次数
                        weibo['reposts'] = itemc.get('reposts_count')  # 转发次数
                        weibo['userid']=itemc.get('user').get('id')   #发布人id
                        weibo['username'] = itemc.get('user').get('screen_name')  # 发布人微博名
                        # 一个一个返回weibo
                        yield weibo
            else:
                continue
#存储到excel中
saveB=1             #标志位用来标记以及存储了多少条数据  还可以在存储时进行行数的标记
datelist=["userid", "username", "date", "attitudes", "comments", "reposts", "text"]
#全局定义excel中的相关参数   因为涉及多次的进行存入工作
book = xlwt.Workbook(encoding="utf-8", style_compression=0)             # 创建workbook对象
sheet = book.add_sheet('微博相关话题博文信息', cell_overwrite_ok=True)      # 创建工作表
col = ("发布人id", "发布人微博名", "发布时间", "点赞次数", "评论次数", "转发次数", "博文内容")
for i in range(0, 7):
    sheet.write(0, i, col[i])    #设置第一行显示内容
#存储到excel中
def save_data_toexcel(datas,savepath):
    global Pqove
    global saveB
    global sheet
    global book
    print("!!!!!!!!存入数据中")
    if  Pqove==1:               #对数据读取全部完成之后存入excel中
        print("存入数据完成！！！！！！！")
        book.save(savepath)
        return
    for j in range(0, 7):
        sheet.write(saveB, j, datas.get(datelist[j]))       #存储数据  saveB用来计数也是标记行数
    print("已存入%d条数据" % saveB)
    saveB+=1
def main():      #main函数
    global Pqove
    bio = 0                 #bio 是用来标记是否连续多个超出规定时间段的博文（连续超过3个就认为博文已经爬取完毕）
    page = 1                #页数  从第一页开始  也是需要传入的一个参数
    while True:
        data = get_page(page)                   #获取网页的json格式的数据
        results = parse_json(data)              #解析网页的json数据
        for result in results:                  #循环去便利数据
            # print(type(result['date']))
            d1 = datetime.strptime(result['date'], '%Y-%m-%d %H:%M:%S') #博文时间
            d2 = datetime.strptime('2022-01-01 00:00:00', '%Y-%m-%d %H:%M:%S')           #结束时间
            d3 = datetime.strptime('2022-10-28 00:00:00', '%Y-%m-%d %H:%M:%S')          #开始时间
            # print(d1)
            # print(d1<d2)
            if d1 >= d3:
                                   #逻辑：  判断时间是否在开始和结束时间之间 如果在那么就存入数据   如果不在修改bio的数据   page++   如果bio达到3那么跳出while
                if d1 <= d2:
                    bio = 0
                    save_data_toexcel(result,savepath)
                    # save_date_tolist(result,savepath)
                    # save_data(result, page)  # 判断是否存入（要求必须是规定时间之内的微博）   判定逻辑：如果出现连续三个时间超过的规定范围那么便停止抓取
                else:
                    bio=0
            else:
                bio += 1
                if bio>=10:
                    Pqove=1
                    save_data_toexcel(result,savepath)
                    break
                    # save_date_tolist(result,savepath)
        print('第' + str(page) + '页抓取完成')
        # print(bio)
        if bio>=10:
            break
        page += 1
if __name__ =='__main__':
    main()