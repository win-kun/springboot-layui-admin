<!DOCTYPE html>
<html lang="en">
<head>
    <script src="/static/js/jquery-3.4.1.min.js"></script>
    <script src="/static/layui/layui.js"></script>
    <link rel="stylesheet" href="/static/layui/css/layui.css">
    <style>

    </style>
</head>
<body>

<!-- 卡片搜索面板-->

<div style="padding: 10px; background-color: #F2F2F2;/*height: 180px;*/">
    <div class="layui-row layui-col-space15">
        <div >
            <div class="layui-card">
                <div class="layui-card-header"><span style="margin-right: 10px; margin-bottom: 2px" class="layui-badge-dot"></span>快速搜索</div>
                <div class="layui-card-body layui-form-item">

                    <div class=" layui-col-md4" style="margin-bottom: 10px;">
                        <label class="layui-form-label">部门</label>
                        <div class="layui-input-block" style="width: 200px">
                            <select id="depart-select" name="department"  style="width:200px;height:38px;border-color: #e6e6e6" >
                                <option style="" value="">请选择部门</option>
                            </select>
                        </div>
                    </div>


                    <div class="layui-col-md4" style="margin-bottom: 10px">
                        <label class="layui-form-label">产品</label>
                        <div class="layui-input-block" style="width: 200px">
                            <select id="product-select" name="position" lay-verify="required" style="width:200px;height:38px;border-color: #e6e6e6">
                                <option value="">请选择产品</option>
                            </select>
                        </div>
                    </div>

                    <div class="layui-col-md4" style="margin-bottom: 10px">
                        <label class="layui-form-label">单号</label>
                        <div class="layui-input-block" style="width: 200px">
                            <input id="search-input-orderNumber" type="text" name="title"  placeholder="请输入计件单号" autocomplete="off" class="layui-input">
                        </div>
                    </div>

                    <div class="layui-col-md4" style="margin-bottom: 10px">
                        <label class="layui-form-label">员工工号</label>
                        <div class="layui-input-block" style="width: 200px">
                            <input id="search-input-employeeNumber" type="text" name="title"  placeholder="请输入员工工号" autocomplete="off" class="layui-input">
                        </div>
                    </div>

                    <div class="layui-col-md4 " style="margin-bottom: 10px;">
                        <label class="layui-form-label">开始日期</label>
                        <div class="layui-input-block">
                            <input id="search-input-startTime" type="text" name="date"  lay-verify="date"  autocomplete="off" class="layui-input" style="width: 200px">
                        </div>
                    </div>

                    <div class="layui-col-md4 " style="margin-bottom: 10px;">
                        <label class="layui-form-label">结束日期</label>
                        <div class="layui-input-block">
                            <input id="search-input-endTime" type="text" name="date"  lay-verify="date"  autocomplete="off" class="layui-input" style="width: 200px">
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>



<table class="layui-hide" id="workOrder-table" lay-filter="workOrder-table"></table>

<script type="text/html" id="toolbar">
    <div class="layui-btn-container" style="float: left;">
        <button class="layui-btn layui-btn-sm" lay-event="addProcess" style="float: left;">添加工序</button>
    </div>
</script>

<script type="text/html" id="barTpl">
    <a class="layui-btn layui-btn-xs" lay-event="edit">保存</a>
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
</script>

<style type="text/css">
    .layui-table-cell{
        height:36px;
        line-height: 36px;
    }
</style>

<script>

    var departs = [];
    var products = [];
    <!-- 向子页面进行数据传递 (下拉框选项, 及主键 -> 不一定连续)-->
    <#list productList as product>
    products.push({
        'id' : '${product.productUuid}',
        'name' : '${product.name}'
    });
    </#list>

    <#list departList as depart>
    departs.push({
        'id' : '${depart.departUuid}',
        'name' : '${depart.departName}'
    });
    </#list>

    for (var i = 0; i < products.length; i++) {
        $("#product-select").append('<option value=' + products[i].id + '>' + products[i].name + '</option>');
    }
    for (var i = 0; i < departs.length; i++) {
        $("#depart-select").append('<option value=' + departs[i].id + '>' + departs[i].name + '</option>');
    }


    function sotitle(id,arr){
        var title;
        $.each(arr, function (index, obj) {
            if(obj.id==id){
                title=obj.name;
            }
        });
        if(title==null){
            return "";
        }else{
            return title;
        }
    };

    var tableContent = [];
    layui.use(['table', 'form', 'layedit', 'laydate'], function(){

        var form = layui.form
            ,layer = layui.layer
            ,layedit = layui.layedit
            ,laydate = layui.laydate;

        //日期
        laydate.render({
            elem: '#search-input-startTime'
            ,type: 'datetime'
            ,theme: 'molv'
            ,done:function(value){//value, date, endDate点击日期、清空、现在、确定均会触发。回调返回三个参数，分别代表：生成的值、日期时间对象、结束的日期时间对象
                startTime(value);
            }
        });
        laydate.render({
            elem: '#search-input-endTime'
            ,type: 'datetime'
            ,theme: 'molv'
            ,done:function(value){//value, date, endDate点击日期、清空、现在、确定均会触发。回调返回三个参数，分别代表：生成的值、日期时间对象、结束的日期时间对象
                endTime(value);

            }
        });

        /*var form = layui.form;*/
        var table = layui.table;
        table.render({
            elem: '#workOrder-table',
            url:'/workOrders',
            toolbar: '#toolbar',
            parseData: function (res) {
                console.log(res);
                tableContent = res.data;
                return {
                    "code": 0,
                    "msg": "",
                    "count": res.size,
                    data: res.data
                }
            }
            ,cols: [[
                {field:'id', width:30, title: 'ID',hide:true},
                {field:'orderUuid', width:30, title: '唯一标识',hide:true},
                {field:'orderNumber', width:100, title: '计件单号'},
                {field:'departUuid', width:100, title: '部门',templet:'<div>{{sotitle(d.departUuid,departs)}}</div>'},
                {field:'productUuid', width:100, title: '产品',templet:'<div>{{sotitle(d.productUuid,products)}}</div>'},
                {field:'color', width:100, title: '颜色'},
                {field:'skuName', width:100, title: '尺码'},
                {field:'number', width:100, title: '数量'},
                {field:'processNumber', width:100, title: '工序数'},
                {field:'employeeNumber', width:100, title: '员工'},
                {field:'createAt', width:200, title: '创建时间', sort: true},
                {fixed: 'right', width:150,title: '操作', align:'center', toolbar: '#barTpl'}
            ]]
            ,page: true
        });


        function startTime(value)
        {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = value;
            var qendTime = $("#search-input-endTime").val();
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        }

        function endTime(value)
        {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = $("#search-input-startTime").val();
            var qendTime = value;
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        }


        /* 搜索实现, 使用reload, 进行重新请求 */
        $("#search-input-orderNumber").on('input',function () {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = $("#search-input-startTime").val();
            var qendTime = $("#search-input-endTime").val();
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        });
        $("#depart-select").on('input',function () {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = $("#search-input-startTime").val();
            var qendTime = $("#search-input-endTime").val();
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        });
        $("#product-select").on('input',function () {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = $("#search-input-startTime").val();
            var qendTime = $("#search-input-endTime").val();
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        });
        $("#search-input-employeeNumber").on('input',function () {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = $("#search-input-startTime").val();
            var qendTime = $("#search-input-endTime").val();
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        });
/*
        $("#search-input-startTime").on('input',function () {

                // 用来传递到后台的查询参数MAP
                var whereData = {};
                var qorderNumber = $("#search-input-orderNumber").val();
                var qdepartUuid = $("#depart-select").val();
                var qproductUuid = $("#product-select").val();
                var qemployeeNumber = $("#search-input-employeeNumber").val();
                var qstartTime = $("#search-input-startTime").val();
                var qendTime = $("#search-input-endTime").val();
                if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
                if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
                if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
                if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
                if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
                if (qendTime.length > 0) whereData["qendTime"] = qendTime;
                table.reload("workOrder-table",{
                    where: {
                        query: JSON.stringify(whereData)
                    }
                    ,page: {
                        curr: 1
                    }
                });
        });
        $("#search-input-endTime").on('input',function () {
            // 用来传递到后台的查询参数MAP
            var whereData = {};
            var qorderNumber = $("#search-input-orderNumber").val();
            var qdepartUuid = $("#depart-select").val();
            var qproductUuid = $("#product-select").val();
            var qemployeeNumber = $("#search-input-employeeNumber").val();
            var qstartTime = $("#search-input-startTime").val();
            var qendTime = $("#search-input-endTime").val();
            if (qorderNumber.length > 0) whereData["qorderNumber"] = qorderNumber;
            if (qdepartUuid.length > 0) whereData["qdepartUuid"] = qdepartUuid;
            if (qproductUuid.length > 0) whereData["qproductUuid"] = qproductUuid;
            if (qemployeeNumber.length > 0) whereData["qemployeeNumber"] = qemployeeNumber;
            if (qstartTime.length > 0) whereData["qstartTime"] = qstartTime;
            if (qendTime.length > 0) whereData["qendTime"] = qendTime;
            table.reload("workOrder-table",{
                where: {
                    query: JSON.stringify(whereData)
                }
                ,page: {
                    curr: 1
                }
            });
        });*/
        var temp;
        form.on('switch(admin_switch)', function (obj) {
            temp = obj.elem.checked;
        });

        table.on('toolbar(workOrder-table)', function (obj) {
            // 回调函数
            layerCallback= function() {
                /*// 执行局部刷新, 获取之前的TABLE内容, 再进行填充
                var dataBak = [];
                var tableBak = table.cache.workOrder-table;
                for (var i = 0; i < tableBak.length; i++) {
                    dataBak.push(tableBak[i]);      //将之前的数组备份
                }
                // 添加到表格缓存
                dataBak.push(callbackData);
                //console.log(dataBak);
                table.reload("workOrder-table",{
                    data:dataBak   // 将新数据重新载入表格
                });*/
                table.render({
                    elem: '#workOrder-table',
                    url:'/workOrders',
                    toolbar: '#toolbar',
                    parseData: function (res) {
                        console.log(res);
                        tableContent = res.data;
                        return {
                            "code": 0,
                            "msg": "",
                            "count": res.size,
                            data: res.data
                        }
                    }
                    ,cols: [[
                        {field:'id', width:30, title: 'ID',hide:true},
                        {field:'orderUuid', width:30, title: '唯一标识',hide:true},
                        {field:'orderNumber', width:100, title: '计件单号'},
                        {field:'departUuid', width:100, title: '部门',templet:'<div>{{sotitle(d.departUuid,departs)}}</div>'},
                        {field:'productUuid', width:100, title: '产品',templet:'<div>{{sotitle(d.productUuid,products)}}</div>'},
                        {field:'color', width:100, title: '颜色'},
                        {field:'skuName', width:100, title: '尺码'},
                        {field:'number', width:100, title: '数量'},
                        {field:'processNumber', width:100, title: '工序数'},
                        {field:'employeeNumber', width:100, title: '员工'},
                        {field:'createAt', width:200, title: '创建时间', sort: true},
                        {fixed: 'right', width:150,title: '操作', align:'center', toolbar: '#barTpl'}
                    ]]
                    ,page: true
                });
            };
            var data = obj.data; //获得当前行数据
            var layEvent = obj.event; //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
            var tr = obj.tr; //获得当前行 tr 的DOM对象
            switch(obj.event){
                case 'addProcess':
                    layer.open({
                        title: '新增计件单',
                        content: 'static/html/layers/workOrder-insert.html',
                        type: 2,
                        offset: 't',
                        area: ["1200px", "600px"],
                        success: function (layero, index) {
                            var iframe = window['layui-layer-iframe' + index];
                            var departs = [];
                            var products = [];
                            <!-- 向子页面进行数据传递 (下拉框选项, 及主键 -> 不一定连续)-->
                            <#list departList as depart>
                            departs.push({
                                'id' : '${depart.departUuid}',
                                'name' : '${depart.departName}'
                            });
                            </#list>
                            <#list productList as product>
                            products.push({
                                'id' : '${product.productUuid}',
                                'name' : '${product.name}'
                            });
                            </#list>
                            var dataDict = {
                                'departs': departs,
                                'products': products
                            };
                            iframe.child(dataDict);
                        }
                    });
            }
        });

        //监听工具条(右侧)
        table.on('tool(workOrder-table)', function(obj){ //注：tool是工具条事件名，test是table原始容器的属性 lay-filter="对应的值"
            var data = obj.data; //获得当前行数据
            var layEvent = obj.event; //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
            var tr = obj.tr; //获得当前行 tr 的DOM对象
            if(layEvent === 'edit'){ //编辑
                console.log($("#depart-select").val());
                // 发送更新请求
                $.ajax({
                    url: '/workOrders',
                    method: 'put',
                    data: JSON.stringify({
                        id: data.id,
                        processName:data.processName,
                        price:data.price,
                        remark:data.remark,
                        status: temp == null ? data.status : temp
                    }),
                    contentType: "application/json",

                    success: function (res) {
                        console.log(res);
                        if (res.code == 200) {
                            layer.msg('更新计件单信息成功', {icon: 1});
                            obj.update({
                                id: data.id,
                                processName:data.processName,
                                price:data.price,
                                remark:data.remark,
                            });
                        } else {
                            layer.msg('更改计件单信息失败', {icon: 2});
                        }
                    }
                });
            } else if (layEvent == 'del') {
                layer.confirm('删除计件单?', {skin: 'layui-layer-molv',offset:'c', icon:'0'},function(index){
                    obj.del(); //删除对应行（tr）的DOM结构，并更新缓存
                    layer.close(index);
                    //向服务端发送删除指令
                    $.ajax({
                        url: '/workOrders/' + data.id,
                        type: 'delete',
                        success: function (res) {
                            console.log(res);
                            if (res.code == 200) {
                                layer.msg('删除成功', {icon: 1, skin: 'layui-layer-molv', offset:'c'});
                            } else {
                                layer.msg('删除失败', {icon: 2, skin: 'layui-layer-molv', offset:'c'});
                            }
                        }
                    })
                });
            }
        });
    });
</script>
</body>
</html>