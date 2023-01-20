// 以下国内疫情数据

// 获取疫情数据
var china_data = [];

var china = {};

// 获取当下国内最新数据
function getDate1() {
  //从网站中拉取相关数据，传入var参数res(result)中
  $.get('https://api.inews.qq.com/newsqa/v1/query/inner/publish/modules/list?modules=statisGradeCityDetail,diseaseh5Shelf', function (res) {
  //china表示所有地区的合集  
  china = res['data']['diseaseh5Shelf']['areaTree'][0].total;
    // console.log(res);
    china_data = res['data']['diseaseh5Shelf']['areaTree'][0]['children'];
    console.log(china_data);

    $('.nowConfirm').html(china.nowConfirm.toLocaleString());
    $('.dead').html(china.dead.toLocaleString());

    let number = china.confirm.toString();
    // console.log(number.toString());
    for (let i = 0; i < number.length; i++) {
      $(".totalConfirm").append(`<li class="data_cage">${number[i]}</li>`)
    }
    // console.log(china_data);
    
    // console.log(china_data);
   
    // 显示地图数据
    map();
    
  })
}
var dayAdd = []
var day = []
// 获取一段时间内数据
function getDate2() {
  $.get('https://api.inews.qq.com/newsqa/v1/query/inner/publish/modules/list?modules=chinaDayList,chinaDayAddList,nowConfirmStatis,provinceCompare', function (res) {
    dayAdd = res["data"]["chinaDayAddList"];
    day = res["data"]["chinaDayList"];
    // console.log(dayAdd);
    // console.log(day);

    //趋势 
    bar1();
  })
}

function getDate4() {
  $.get('https://lab.isaaclin.cn/nCoV/api/news?page=1&num=10', function (res) {
    // console.log(res.results);
    var news = res.results;
    $('.news').html('');
    for (let i = 0; i < news.length; i++) {
      $('.news').append(
        `
        <div class="message_scroll">
          <div class="scroll_top">
            <span class="scroll_title">${news[i].title.split('|')[0]}</span>
            <span class="scroll_timer">${(new Date(Number(news[i].pubDate)).getMonth() + 1) + "/" + new Date(Number(news[i].pubDate)).getDate()}</span>
          </div>
          <div class="msg_cage"> <a class="localize_msg">${news[i].summary}</a></div>
          <div class="msg_cage"> <a class="localize_title" href=${news[i].sourceUrl}>${news[i].infoSource}</a></div>
        </div>
        `
      )
    }
  });

}
// console.log(china_data);
getDate1();
getDate2();
getDate4();

// 新冠新增确诊排序函数
function sortA(a, b) {
  return b.today.confirm + b.today.wzz_add - a.today.confirm - a.today.wzz_add;
}
// 累计确诊排序
function sortB(a, b) {
  return b.total.confirm + b.total.wzz - a.total.confirm - a.total.wzz;
}
function sortC(a, b) {
  return b.confirmAdd - a.confirmAdd;
}
function sortD(a, b) {
  return b.nowConfirm - a.nowConfirm;
}
function calMax(arr) {
  var max = Math.max.apply(null, arr); // 获取最大值方法
  var maxint = Math.ceil(max / 5); // 向上以5的倍数取整
  var maxval = maxint * 5 + 5; // 最终设置的最大值
  return maxval; // 输出最大值
}
// 获取最小值方法
function calMin(arr) {
  var min = Math.min.apply(null, arr); // 获取最小值方法
  var minint = Math.floor(min / 1); // 向下以1的倍数取整
  var minval = minint * 1 - 5; // 最终设置的最小值
  return minval; // 输出最小值
}





//鼠标点击省份的时候进行转跳
function OnClickProvince(mouseEvent, province) {
  if (mouseEvent.button == 0)
    console.log("clicked: " + province);
    //当点击到的是省份才进行转跳
    if(province!=null)
    {
    }

}

//点击词云的函数
function OnClickWordCloud(mouseEvent,word)
{
  if(mouseEvent.button==0)
    {
      console.log("clicked:"+ word);
    }
}




// 显示所有国内省份疫情信息的地图
function map() {
  //
  var dataMap = [];
  for (let i = 0; i < china_data.length; i++) {
    //对地图输入数据
    dataMap.push({ name: china_data[i]['name'],
     value: china_data[i]['total'].nowConfirm,
     wzz: china_data[i]['total'].wzz,
     localconfirm: china_data[i]['total'].provinceLocalConfirm,
     confirm: china_data[i]['total'].confirm })
  }
  dataMap.push({ name: "南海诸岛", value: 0 ,wzz:0});
  // 需要在页面上直接标记出来的城市
  var specialMap = [];
  // 对dataMap进行处理，使其可以直接在页面上展示
  for (var i = 0; i < specialMap.length; i++) {
    for (var j = 0; j < dataMap.length; j++) {
      if (specialMap[i] == dataMap[j].name) {
        dataMap[j].selected = true;
        break;
      }

    }
  }

  var currentProvince = null;

  var option = {
    tooltip: {
      formatter: function (params) {
        var info = '<p style="font-size:18px">' + params.name +
         '</p><p style="font-size:14px">' + '现有确诊：'+params.value.toLocaleString() +
         '</p><p style="font-size:14px">'+'无症状：'+params.data.wzz+
         '</p><p style="font-size:14px">'+'累计确诊：'+params.data.confirm+
         '</p><p style="font-size:14px">'+'本土确诊：'+params.data.localconfirm+
         '</p>';
        currentProvince = params.name;
        //  console.log(params.name);
        //  console.log(params.value);
        console.log(params);
        //console.log(params);
        return info;
      },
      backgroundColor: "#ff7f50",//提示标签背景颜色
      textStyle: { color: "#fff" } //提示标签字体颜色
    },


    //左侧小导航图标
    visualMap: {
      show: true,
      x: 'left',
      y: 'bottom',
      splitList: [
        { start: 1000000, end: 9999999 },
        { start: 100000, end: 999999 },
        { start: 10000, end: 99999 },
        { start: 1000, end: 9999 }, { start: 500, end: 999 },
        { start: 100, end: 499 }, { start: 10, end: 99 },
        { start: 1, end: 9 }, { start: 0, end: 0 },
      ],
      color: ['#8b0000', '#ff0505', '#CC1E1E', '#F04141', '#FFAA80', '#FFC89E', '#FFE7B8', '#E4E8F3',],
      textStyle: {
        color: "#F0F8FF",
        frontsize: 16
      }
    },
    series: [
      {
        name: '中国',
        type: 'map',
        mapType: 'china',
        label: {
          normal: {
            show: false,//显示省份标签
          },
          emphasis: {
            show: false,//对应的鼠标悬浮效果
          }
        },
        data: dataMap
      }
    ]
  };
  //初始化echarts实例
  var myChart = echarts.init(document.getElementById('map'));
  //使用制定的配置项和数据显示图表
  myChart.setOption(option);
  window.addEventListener("resize", function () { myChart.resize(); });
  //添加点击省份的事件
  window.addEventListener("mousedown", function (e) 
  {
    var elem = document.querySelector("#map > div:nth-child(2)");
    if (elem.innerHTML == "" || elem.style.visibility == "hidden")
      currentProvince = null;
    OnClickProvince(e, currentProvince);
  });
}

// 国内现有确诊趋势
// ! unused
function bar1() {
  var myChart = echarts.init(document.getElementById('bar1'));
  let xdata = [];
  let nowConfirm = [];
  let addconfirm = [];
  for (let i = 0; i < day.length; i++) {
    xdata.push(day[i].date);
    addconfirm.push(dayAdd[i].localConfirmadd);
    nowConfirm.push(day[i].localConfirm);
  }
  // 调用方法，获取数据的最大值&最小值
  var maxData1 = calMax(nowConfirm);
  var maxData2 = calMax(addconfirm);
  var minData1 = calMin(nowConfirm);
  var minData2 = calMin(addconfirm);

  //
  option = {
    tooltip: {
      trigger: 'axis',
    },
    legend: {
      top: '5%',
      textStyle:
      {
        color: "#F0F8FF"
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '15%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      axisLine: {
        lineStyle: {
          color: "#F0F8FF"
        }
      },
      data: xdata,
    },
    yAxis: [
      {
        type: 'value',
        position: 'left',
        min: minData1,
        max: maxData1,
        splitNumber: 5, //设置坐标轴的分割段数
        interval: (maxData1 - minData1) / 5, // 标轴分割间隔
        axisLabel: {
          formatter: function (v) {
            return v.toFixed(0); //0表示小数为0位，1表示1位小数，2表示2位小数
          },
        },
        axisLine: {
          lineStyle: {
            color: "#F0F8FF"
          }
        }
      },
      {
        type: 'value',
        position: 'right',
        // alignTicks: true,
        min: minData2,
        max: maxData2,
        splitNumber: 5, //设置坐标轴的分割段数
        interval: (maxData2 - minData2) / 5, // 标轴分割间隔
        axisLabel: {
          formatter: function (v) {
            return v.toFixed(0); //0表示小数为0位，1表示1位小数，2表示2位小数
          },
        },
        axisLine: {
          // show: true,
          lineStyle: {
            color: "#F0F8FF"
          }
        },
      }
    ],

    series: [
      {
        name: '全国现有确诊趋势',
        data: nowConfirm,
        type: 'line',
        smooth: true,

      },
      {
        name: '全国疫情新增趋势',
        data: addconfirm,
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
      },
    ]
  };
  //使用制定的配置项和数据显示图表
  myChart.setOption(option);
  window.addEventListener("resize", function () { myChart.resize(); });
}

// leijitop()
// bar1()
//——————————————————————————————————————————————————————————以上国内疫情——————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————以下国内舆情——————————————————————————————————————————————————————————


//词云图
function word_cloud() {
  var myChart = echarts3.init(document.getElementById('word_cloud'));
  window.addEventListener("resize", function () {
    myChart.resize();
  });
  var keywords = [
    { name: ' 乌鲁木齐', value: 14600 },
    { name: ' 郑州', value: 14339 },
    { name: ' 福州', value: 13500 },
    { name: ' 核酸', value: 12223 },
    { name: ' 采样', value: 11254 },
    { name: ' 小区', value: 11227 },
    { name: ' 确诊', value: 10830 },
    { name: ' 封控', value: 10613 },
    { name: ' 解封', value: 10116 },
    { name: ' 病例', value: 10110 },
    { name: ' 广州', value: 9779 },
    { name: ' 南京', value: 9310 },
    { name: ' 发布会', value: 8829 },
    { name: ' 高风险', value: 5619 },
    { name: ' 白云区', value: 5416 },
    { name: ' 富士康', value: 5219 },
    { name: ' 西安', value: 5187 },
    { name: ' 肺炎', value: 4885 },
    { name: ' 无症状', value: 4473 },
    { name: ' 检测', value: 4458 },
    { name: ' 河南', value: 4420 },
    { name: ' 社区', value: 4113 },
    { name: ' 居家', value: 4102 },
    { name: ' 传播', value: 3996 },
    { name: ' 健康', value: 3976 },
    { name: ' 目前', value: 3924 },
    { name: ' 封校', value: 3729 },
    { name: ' 隔离', value: 3687 },
    { name: ' 新增', value: 3611 },
    { name: ' 可能', value: 3593 },
    { name: ' 出现', value: 3524 },
    { name: ' 治愈', value: 3484 },
    { name: ' 时间', value: 3364 },
    { name: ' 需要', value: 3309 },
    { name: ' 发现', value: 3303 },
    { name: ' 本土', value: 3218 },
    { name: ' 发热', value: 3204 },
    { name: ' 专家', value: 3040 },
    { name: ' 消毒', value: 3031 },
    { name: ' 人员', value: 3026 },
    { name: ' 生活', value: 2989 },
    { name: ' 症状', value: 2972 },
    { name: ' 情况', value: 2962 },
    { name: ' 物资', value: 2961 },
    { name: ' 平安', value: 2930 },
    { name: ' 人民', value: 2868 },
    { name: ' 打卡', value: 2853 },
    { name: ' 防护', value: 2842 },
    { name: ' 发布', value: 2837 },
    { name: ' 酒吧', value: 3729 },
    { name: ' 看到', value: 2835 },
    { name: ' 上班', value: 2817 },
    { name: ' 所有', value: 2765 },
    { name: ' 医用', value: 2673 },
    { name: ' 问题', value: 2642 },
    { name: ' 社区', value: 2626 },
    { name: ' 起来', value: 2612 },
    { name: ' 卫健委', value: 2581 },
    { name: ' 停课', value: 2581 },
    { name: ' 酒精', value: 2579 },
    { name: ' 医疗', value: 2549 },
    { name: ' 预防', value: 2503 },
    { name: ' 进行', value: 2497 },
    { name: ' 转发', value: 2493 },
    { name: ' 很多', value: 2490 },
    { name: ' 检测', value: 2490 },
    { name: ' 病人', value: 2436 },
    { name: ' 不会', value: 2435 },
    { name: ' 路径', value: 2415 },
    { name: ' 每天', value: 2413 },
    { name: ' 聚集', value: 2390 },
    { name: ' 咳嗽', value: 2371 },
    { name: ' 努力', value: 2341 },
    { name: ' 一下', value: 2326 },
    { name: ' 疫苗', value: 2276 },
    { name: ' 黄码', value: 2252 },
    { name: ' 出门', value: 2238 },
    { name: ' 疾病', value: 2229 },
    { name: ' 防疫', value: 2218 },
    { name: ' 感谢', value: 2198 },
    { name: ' 捐赠', value: 2197 },
    { name: ' 区域', value: 2182 },
    { name: ' 应该', value: 2180 },
    { name: ' 关注', value: 2145 },
    { name: ' 做好', value: 2134 },
    { name: ' 抗疫', value: 2122 },
    { name: ' 期间', value: 2093 },
    { name: ' 企业', value: 2068 },
    { name: ' 这种', value: 2017 },
    { name: ' 接触', value: 2009 },
    { name: ' 发烧', value: 1989 },
    { name: ' 保护', value: 1927 },
    { name: ' 表示', value: 1913 },
    { name: ' 最新', value: 1892 },
    { name: ' 累计', value: 1891 },
    { name: ' 出来', value: 1888 },
    { name: ' 组织', value: 1881 },
    { name: ' 今日', value: 1876 }
  ]

  var maskImage = new Image();

  maskImage.src = "data:image/png;base64,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"
  var option = {
    backgroundColor: '#fff',
    series: [{
      type: 'wordCloud',
      sizeRange: [10, 100],
      rotationRange: [0, 0],
      rotationStep: 0,
      gridSize: 2,
      width: '100%',
      height: '100%',

      maskImage: maskImage,
      textStyle: {
        normal: {
          color: function () {
            return 'rgb(' + [
              Math.round(Math.random() * 160),
              Math.round(Math.random() * 160),
              Math.round(Math.random() * 160)
            ].join(',') + ')';
          }
        },
        emphasis: {
          shadowBlur: 10,
          shadowColor: '#333'
        }

      },
      data: keywords
    }]
    
  
  };

  maskImage.onload = function () 
  {   /* 自定义形状，关键点4*/
    myChart.setOption(option);
  };

    //添加鼠标点击词云的事件
    window.addEventListener("mousedown",function(e)
    {
      var elem =document.querySelector("#word_cloud > div");
      OnClickWordCloud(e,data.keywords.name);
    });

  //   window.addEventListener("mousedown", function (e) 
  //   {
  //     var elem = document.querySelector("#map > div:nth-child(2)");
  //     if (elem.innerHTML == "" || elem.style.visibility == "hidden")
  //       currentProvince = null;
  //     OnClickProvince(e, currentProvince);
  // });

}

function tfidfbar() {
  
}

function yuqingpie() {
 
}

