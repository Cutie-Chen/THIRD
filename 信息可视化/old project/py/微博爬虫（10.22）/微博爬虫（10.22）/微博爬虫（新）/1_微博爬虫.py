
import os
import re  # 正则表达式提取文本
from jsonpath import jsonpath  # 解析json数据
import requests  # 发送请求
import pandas as pd  # 存取csv文件
import datetime  # 转换时间用
import urllib.parse
from urllib.parse import urlencode
from pyquery import PyQuery as pq

def trans_time(v_str):
	"""转换GMT时间为标准格式"""
	GMT_FORMAT = '%a %b %d %H:%M:%S +0800 %Y'
	timeArray = datetime.datetime.strptime(v_str, GMT_FORMAT)
	ret_time = timeArray.strftime("%Y-%m-%d %H:%M:%S")
	return ret_time

search="疫情"
urlsearch=urllib.parse.quote('=1&q='+search)     #进行url编码
m_referer='https://m.weibo.cn/search?containerid=100103type'   #微博搜索来源界面
headers = {                 #封装请求头  让网站识别自己是浏览器
    'Referer': m_referer+urlsearch,             #告诉服务器自己是哪里来的  从那个页面来的   来路
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36 Edg/80.0.361.111',    #包含操作系统和浏览器信息
    'Host':'m.weibo.cn',                #请求服务器的域名和端口号
    'X-Requested-With':'XMLHttpRequest'             #代表是ajax请求
}

#获取全文网页的json（这个是获取需要对全文获取的网页的json数据的函数）
def get_txt_page(containerid):
    base_urlx = 'https://m.weibo.cn/statuses/show?'     #相较于获取搜索结果的url不通
    txtheaders = {
        # 'Referer': referer,
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


def getScheme(bid,schemelist):
	for scheme in schemelist:
		if scheme.find(bid)!=-1:
			return scheme

def get_weibo_list(v_keyword, v_max_page):
	"""
	爬取微博内容列表
	:param v_keyword: 搜索关键字
	:param v_max_page: 爬取前几页
	:return: None
	"""
	# 请求头
	headers = {
		"User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Mobile Safari/537.36",
		"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
		"accept-encoding": "gzip, deflate, br",
	}
	for page in range(1, v_max_page + 1):
		print('===开始爬取第{}页微博==='.format(page))
		# 请求地址
		url = 'https://m.weibo.cn/api/container/getIndex'
		# 请求参数
		params = {
			"containerid": "100103type=1&q={}".format(v_keyword),
			"page_type": "searchall",
			"page": page
		}
		# 发送请求
		r = requests.get(url, headers=headers, params=params)
		#状态码
		print(r.status_code)
		# pprint(r.json())
		# 解析json数据
		cards = r.json()["data"]["cards"]
		# 微博内容
		text_list = jsonpath(cards, '$..mblog.text')
		# 微博内容-正则表达式数据清洗
		dr = re.compile(r'<[^>]+>', re.S)
		text2_list = []
		print('text_list is:')
		# print(text_list)


		#
		# Zdata=r.json()
		# items = Zdata.get('data').get('cards')
		scheme_list = jsonpath(cards, '$..scheme')
		print(scheme_list)
		# print(scheme_list.index("https://m.weibo.cn/status/"))
		#
		if not text_list:  # 如果未获取到微博内容，进入下一轮循环
			continue
		if type(text_list) == list and len(text_list) > 0:
			for text in text_list:
				text2 = dr.sub('', text)  # 正则表达式提取微博内容
				text2_list.append(text2)
		# 微博创建时间
		time_list = jsonpath(cards, '$..mblog.created_at')
		time_list = [trans_time(v_str=i) for i in time_list]
		# 微博作者
		author_list = jsonpath(cards, '$..mblog.user.screen_name')
		# 微博id
		id_list = jsonpath(cards, '$..mblog.id')
		# 微博bid
		bid_list = jsonpath(cards, '$..mblog.bid')
		# 转发数
		reposts_count_list = jsonpath(cards, '$..mblog.reposts_count')
		# 评论数
		comments_count_list = jsonpath(cards, '$..mblog.comments_count')
		# 点赞数
		attitudes_count_list = jsonpath(cards, '$..mblog.attitudes_count')


		#
		sign=0
		dsign=0
		# print(len(text_list),len(id_list),len(bid_list))
		# for textZ in text2_list:
		# 	print(textZ)
		# 	print("~~~~~~~~~~~~~~~~")
		# print(bid_list)
		for textZ in text2_list:
			if textZ.find("全文")+2==len(textZ):
				# print("!!!!!!!")
				# print(sign)
				# print(textZ)
				# print("hhhhhh")
				# print(bid_list[sign])
				dataz=get_txt_page(bid_list[sign])
				txtitem= pq(dataz.get('data').get('text')).text()
				txtitem=txtitem.replace('\n', '')
				txtitem = txtitem.replace(' ', '')

				# print(txtitem)
				text2_list[dsign]=txtitem
				sign = sign + 1
			else:
				# print(sign)
				# print(textZ)
				# # print("hhhhhh")
				# print(bid_list[sign])
				dataz = get_txt_page(bid_list[sign])
				txtitem = pq(dataz.get('data').get('text')).text()

				if textZ[:8]==txtitem[:8]:
					sign = sign + 1
				txtitem = txtitem.replace('\n', '')
				txtitem = txtitem.replace(' ', '')
				text2_list[sign] = txtitem

			dsign=dsign+1
		# 把列表数据保存成DataFrame数据
		df = pd.DataFrame(
			{
				'页码': [page] * len(id_list),
				'微博id': id_list,
				# '微博bid': bid_list,
				'微博作者': author_list,
				'发布时间': time_list,
				'微博内容': text2_list,
				'转发数': reposts_count_list,
				'评论数': comments_count_list,
				'点赞数': attitudes_count_list,
			}
		)
		# 表头
		if os.path.exists(v_weibo_file):
			header = None
		else:
			header = ['页码', '微博id', '微博作者', '发布时间', '微博内容', '转发数', '评论数', '点赞数']  # csv文件头
		# 保存到csv文件
		df.to_csv(v_weibo_file, mode='a+', index=False, header=header, encoding='utf_8_sig')
		# print('csv保存成功:{}'.format(v_weibo_file))


if __name__ == '__main__':
	# 爬取前几页
	max_search_page = 20  # 爬前n页
	# 爬取关键字
	search_keyword = '疫情'
	# 保存文件名
	v_weibo_file = '微博清单_{}_前{}页.csv'.format(search_keyword, max_search_page)
	# 如果csv文件存在，先删除之
	if os.path.exists(v_weibo_file):
		os.remove(v_weibo_file)
		print('微博清单存在，已删除: {}'.format(v_weibo_file))
	# 调用爬取微博函数
	get_weibo_list(v_keyword=search_keyword, v_max_page=max_search_page)
	# 数据清洗-去重
	df = pd.read_csv(v_weibo_file)
	# 删除重复数据
	# df.drop_duplicates(subset=['微博bid'], inplace=True, keep='first')
	# 再次保存csv文件
	df.to_csv(v_weibo_file, index=False, encoding='utf_8_sig')
	print('数据清洗完成')
