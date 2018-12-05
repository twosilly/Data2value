import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    id:root
    width: 640
    height: 480
    title: qsTr("温度转换")
    ListModel {
        id: chatContent
        ListElement {
            content: "计算温度数据:"
        }
    }
    Rectangle {
        id: chatBox
        opacity: 0.5

       // anchors.centerIn: root.
        color: "#5d5b59"
        border.color: "black"
        border.width: 1
        radius: 5
        anchors.fill: parent

        function sendMessage()
        {
            // 切换焦点以强制输入方法作曲家结束
            var hasFocus = input.focus;
            input.focus = false;

            var data = input.text
            input.clear()
            //判断数据是否正确 005102951db32e22 --> 0051 0295 1db32e22
            if (data.length < 16)
                data =data + ":"+"数据输入有误请检查输入"
//            var Tvalue = data.substring(0,4)
//            var Vvalue = data.substring(4,8)
               var Mvalue = data.substr(8,18)
//            var value = data.substring(0,8)
            //去掉回车换行
            data = data.replace(/[\r\n]/g,"");
            data = data.replace(/\ +/g,""); //去掉空格
            var T = thermometer(data)
            var V = voltage(data) / 3.6 * 100
            T = T.toFixed(3);
            V = V.toFixed(3);
            data ="温度:"+T+" 摄氏度,电量:%"+V+",地址:"+ Mvalue +"-->"+data
            chatContent.append({content: "Me: " + data})

            chatView.positionViewAtEnd()

            input.focus = hasFocus;
        }

        function thermometer(value)
        {
            //console.log(value,parseInt(value.substr(0,4),16),value.substr(4,4));
            //string V0: "00AC03B0"
            var V0 = parseInt(value.substr(0,4),16);//! 温感电压 00AC
            var V1 = parseInt(value.substr(4,4),16);//! 电池电压 03B0
            var Val = (V1*3.6)/1024; //实际供电电压
            var Vr  = (V0*3.6)/1024; //热敏电阻电压
            var R0  = 10000
            var Rr  = (3.6-Vr)*R0/Vr;//R热
            var B   = 3950;//热敏电阻出厂参数
            var T2  = 273.15+25;//25度下华氏温度的值
            //var Tc  = B*T2 / (B + T2*Math.log(x))
            var R = 50000; //25度下的电阻值
            var Tc  = 1/( ( (Math.log(Rr/R)) / B) + (1/T2)) - 273.15 +0.5
            var Tcc = B*T2 / (B+T2*Math.log(Rr/R)) - 273.15 +0.5;
            console.log("电压：V0:",Vr);
            console.log("电压：V1:",Val);
            console.log("供电电压：",Val);
            console.log("热敏电压：",Val-Vr);
            console.log("R热",Rr);
            console.log("实际温度：",Tc,Tcc);
            return Tc
        }

        function voltage(value){
            var V1 = parseInt(value.substr(4,4),16);//! 电池电压 03B0
            var Val = V1*3.6/1024; //实际供电电压
            return Val;
        }

        Item {
            anchors.fill: parent
            anchors.margins: 10

            InputBox {
                id: input
                Keys.onReturnPressed: chatBox.sendMessage()
                height: sendButton.height
                width: parent.width - sendButton.width - 15
                anchors.left: parent.left
            }

            Button {
                id: sendButton
                anchors.right: parent.right
                label: "计算"
                onButtonClick: chatBox.sendMessage()
            }


            Rectangle {
                height: parent.height - input.height - 15
                width: parent.width;
                color: "#d7d6d5"
                anchors.bottom: parent.bottom
                border.color: "black"
                border.width: 1
                radius: 5

                ListView {
                    id: chatView
                    width: parent.width-5
                    height: parent.height-5
                    anchors.centerIn: parent
                    model: chatContent
                    clip: true
                    delegate: Component {
                        Text {
                            font.pointSize: 14
                            text: modelData
                        }
                    }
                }
            }
        }
    }

}
