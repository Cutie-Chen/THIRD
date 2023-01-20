# 请求网页
import requests
# 数据处理
import pandas as pd
# 日期处理
import time

# 获取疫情数据函数
def getdata(url, headers):
    data = requests.get(url, headers)
    # print(data.status_code)#200
    # print(data.encoding)#utf-8
    # data.encoding = 'utf-8'
    return data


# 调用函数
url = 'https://api.inews.qq.com/newsqa/v1/query/inner/publish/modules/list?modules=statisGradeCityDetail,diseaseh5Shelf'
headers = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36 Edg/100.0.1185.29'}
data = getdata(url, headers)
# print(data.text)

# 寻找累计数据
china_data = data.json()['data']['diseaseh5Shelf']['areaTree'][0]['children']

# 存放数据
data_li = []
for child in china_data:
    # print(child['name'])
    data_dict = {}
    # 地区名称
    data_dict['province'] = child['name']
    # 新增确认
    data_dict['nowConfirm'] = child['total']['nowConfirm']
    # 死亡人数
    data_dict['dead'] = child['total']['dead']
    # 治愈人数
    data_dict['heal'] = child['total']['heal']
    # 累计确诊
    data_dict['confirm'] = child['total']['confirm']
    # 本土确诊
    data_dict['provinceLocalConfirm'] = child['total']['provinceLocalConfirm']
    # 死亡率
    data_dict['showRate'] = child['total']['showRate']
    # 治愈率
    data_dict['showHeal'] = child['total']['showHeal']
    # 无症状
    data_dict['wzz'] = child['total']['wzz']
    # print(data_dict)
    data_li.append(data_dict)

# print(data_li)
#转化为dataframe类型，根据当天时间命名csv文件
df = pd.DataFrame(data_li)
today = time.strftime('%Y年%m月%d日', time.localtime())
df.to_csv(today+'全国疫情累计数据.csv',encoding='gbk')
