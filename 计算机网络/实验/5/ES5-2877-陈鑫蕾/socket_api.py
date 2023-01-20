import os
import random
import time
import sys

start_time=time.time()

licensenum=0
maxnum=50
connectnum=0

# #编译服务器和客户端
cserver="g++ .\server.c -o .\EXE\server -lwsock32"
cclient="g++ .\client.c -o .\EXE\client -lwsock32"
os.system(cserver)
os.system(cclient)

#发放许可证
while(True):
    username=input("请输入用户名：")
    password=input("请输入口令：")
    type=input("请输入许可证类型：")
    licensenum=licensenum+1
    flag=0 #记录访问次数
    usednum=[] #记录使用过的序列号

    #打开服务器
    open_server=".\EXE\server"
    os.system(open_server)

    num=random.randint(1000000000,9999999999) #随机生成十位数序列号
    for i in range(len(usednum)): #判断该序列号是否使用过
        if(usednum[i]==num):
            num=random.randint(1000000000,9999999999)
            i=0

    usednum.append(num)
    print("您的序列号是："+str(num)+'\n') #输出序列号

#显示发放许可证数量和连接人数
    print("是否需要连接软件（Y/N）：")
    need=input()
    #此处可退出
    if(need=='N'):
        print("欢迎下次使用！")
        break
    else:
        if(flag==0):
            input_num=input("请输入您的序列号：")
            if(connectnum<maxnum):
                find=0
                for i in range(len(usednum)): #判断该序列号是否使用过
                    if(str(usednum[i])==str(num)):
                        #print(str(used_num[i]))
                        find=1
                        break
                if(find==0):
                    print("输入的序列号有误，无法连接软件！")
                else:
                    create_client=".\EXE\server" #用户运行软件，向许可证服务器发送验证
                    os.system(create_client)

                    end_time=time.time()
                    if(end_time-start_time>10):
                        start_time=time.time()
                        print("当前许可证发放"+str(licensenum)+"张")
                        print("目前有"+str(len(usednum))+"人在使用该软件")
            else:
                #达到最大连接人数时退出程序
                print("目前许可证使用已达到最大人数，无法连入")