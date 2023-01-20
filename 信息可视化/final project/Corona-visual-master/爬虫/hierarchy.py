# -*- coding: utf-8 -*-
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import jieba
import matplotlib.pyplot as plt
from pylab import mpl
from collections import Counter
from sklearn.metrics.pairwise import cosine_similarity
from scipy.cluster.hierarchy import ward, dendrogram
from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer

mpl.rcParams['font.sans-serif'] = ['SimHei']

#------------------------------ 第一步 计算TOP100 ------------------------------
# 计算中文分词词频TOP100
datapd = pd.read_csv('微博清单_疫情_前20页.csv')

cut_words = ""
all_words = ""

for line in datapd['微博内容']:
    line = str(line)
    seg_list = jieba.cut(line,cut_all=False)
    cut_words = (" ".join(seg_list))
    all_words += cut_words

    
# 输出结果
all_words = all_words.split()

# 词频统计
c = Counter()
for x in all_words:
    if len(x)>1 and x != '\r\n':
        c[x] += 1

# 输出词频最高的前10个词
top_word = []
print('\n词频统计结果：')
for (k,v) in c.most_common(50):
    print("%s:%d"%(k,v))
    top_word.append(k)
# ['疫情', '防控', '组织', '工作'...]

#------------------------------ 第二步 中文分词过滤 ------------------------------
# 过滤
cut_words = ""
f = open('C-key.txt', 'w')
datapd = pd.read_csv('微博清单_疫情_前20页.csv')
for line in datapd['微博内容']:
    line = str(line)
    seg_list = jieba.cut(line,cut_all=False)
    final = ""
    for seg in seg_list:
        if seg in top_word:
            final += seg + "|"
    cut_words += final
    f.write(final+"\n")
#print(cut_words)
f.close

