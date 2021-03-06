<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#clueRemark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","#FF0000");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		//页面加载完毕后，取出关联的市场活动信息列表
		showActivityList();

		//	打开关联市场活动窗口之前将关联项，复选框清空
		$("#boundActivityBtn").click(function (){
			$("#activityName").val("");
			$("#activitySearchBody").html("");
			$("#checkbox").prop("checked",false);
		})

		//	为关联市场活动的模态窗口中的 搜索框 绑定事件，通过触发回车键，查询并展示所需市场活动列表
		$("#activityName").keydown(function (event){
			//	如果是回车键
			if (event.keyCode == 13){
				$.ajax({
					url: "workbench/clue/getActivityListByNameAndNotByClueId.do",
					data: {
						"activityName": $.trim($("#activityName").val()),
						"clueId": "${clue.id}"
					},
					type: "get",
					success: function (data){
						/*
							data
								[{活动1},{2},{3}]
						 */
						var html = "";
						$.each(data,function (index,activity){
							html += "<tr>";
							html += "<td><input type=\"checkbox\" name='checkboxItem' value='"+ activity.id +"'/></td>";
							html += "<td>"+ activity.name +"</td>";
							html += "<td>"+ activity.startDate +"</td>";
							html += "<td>"+ activity.endDate +"</td>";
							html += "<td>"+ activity.owner +"</td>";
							html += "</tr>";
						})
						$("#activitySearchBody").html(html);
					}
				})

				//	展现完列表后，记得禁用模态窗口默认的回车行为
				return false;
			}
		})

		//	为总复选框绑定全选操作
		$("#checkbox").click(function (){
			$("input[name=checkboxItem]").prop("checked",this.checked);
		})

		//	其他子复选框操作总复选框
		$("#activityTable").on("click",$("input[name=checkedItem]"),function (){
			$("#checkbox").prop("checked",$("input[name=checkboxItem]").length == $("input[name=checkboxItem]:checked").length);

		})

		//	为关联按钮绑定事件，执行关联表的添加操作
		$("#boundBtn").click(function (){
			//	获取挑勾的复选框
			var $checkboxItems = $("input[name=checkboxItem]:checked");

			if ($checkboxItems.length == 0){
				alert("请选择要关联的活动");
			}else {
				//	肯定选择了
				//	workbench/clue/boundActivity.do?clueId=xxx&activityId=xxx&activityId=xxx...
				var parameter = "clueId=${clue.id}&";
				$.each($checkboxItems,function (index,checkboxItem){
					parameter += "activityId=" + $(checkboxItem).val();
					if (index < $checkboxItems.length - 1){
						parameter += "&";
					}
				})
			}

			$.ajax({
				url: "workbench/clue/boundActivity.do",
				data: parameter,
				type: "post",
				success: function (data){
					/*
						data
							{"success":true/false,"msg":...}
					 */
					if (data.success){
						//	添加成功，刷新市场列表
						showActivityList();

						//	将复选框的√取消、文本框中的内容清除、清空activitySearchBody中的内容
						$("#checkbox").prop("checked",false);
						$("#activityName").val("");
						$("#activitySearchBody").html("");

						//	关闭模态窗口
						$("#bundModal").modal("hide");
					}else {
						alert(data.msg);
					}
				}
			})
		})

        showClueRemarkList();

        $("#remarkBody").on("mouseover",".remarkDiv",function(){
            $(this).children("div").children("div").show();
        })
        $("#remarkBody").on("mouseout",".remarkDiv",function(){
            $(this).children("div").children("div").hide();
        })

		//	保存备注按钮
		$("#saveClueRemarkBtn").click(function (){

			$.ajax({

				url: "workbench/clue/saveClueRemark.do",
				data: {
					"noteContent": $("#clueRemark").val(),
					"clueId": "${clue.id}",
					"createBy": "${user.name}",
					"editFlag": "0"
				},
				type: "post",
				success: function (data){
					if (data.success){

						//	添加成功
						//	把textarea中的信息清空
						$("#clueRemark").val("");

						showClueRemarkList();
					}else {
						alert(data.msg);
					}
				}
			})
		})

		//	为更新按钮绑定事件
		$("#updateRemarkBtn").click(function (){
			var id = $("#remarkId").val();

			$.ajax({
				url: "workbench/clue/updateRemark.do",
				data: {
					//	id,noteContent,editBy,editFlag
					"id": id,
					"noteContent": $.trim($("#noteContent").val()),
					"editBy": "${user.name}",
					"editFlag": "1"
				},
				type: "post",
				dataType: "json",
				success: function (data){
					/*
                        data
                            {"success":true/false,"msg":更新成功还是失败,"customerRemark":{备注}}
                            备注中包括：修改后的信息noteContent，修改时间editTime，修改人editBy
                     */
					if (data.success){
						//	修改备注成功
						//	更新div中相应的信息，需要更新的内容有 noteContent、editTime、editBy
						$("#h5"+ id).html(data.clueRemark.noteContent);
						$("#small"+ id).html(data.clueRemark.editTime+" 由"+data.clueRemark.editBy);

						//	更新之后，关闭模态窗口
						$("#editRemarkModal").modal("hide");
					}else {
						//	修改备注失败
						alert(data.msg);
					}
				}
			})
		})
	});

	showActivityList = function (){
		$.ajax({
			url: "workbench/clue/getActivityListByClueId.do",
			data: {
				"clueid": "${clue.id}"
			},
			type: "get",
			success: function (data){
				/*
					data
						[{市场活动1},{2},{3}]
				 */
				var html = "";

				$.each(data,function (index,activity){
					html += "<tr>",
					html += "<td>"+ activity.name +"</td>",
					html += "<td>"+ activity.startDate +"</td>",
					html += "<td>"+ activity.endDate +"</td>",
					html += "<td>"+ activity.owner +"</td>",
					html += "<td><a href=\"javascript:void(0);\" onclick='unbound(\""+ activity.id +"\")' style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>解除关联</a></td>",
					html += "</tr>"
				})
				$("#activityBody").html(html);
			}
		})
	}

	//	id:我们想要一个关联关系表的id
	//	删除一个市场活动
	function unbound(id){
		if (confirm("你确定要解除关联吗?")){
			$.ajax({
				url: "workbench/clue/unboundByTcarId.do",
				data: {
					"tcarId": id
				},
				type: "get",
				success: function (data){
					/*
						data
							["success":true/false,"msg":"错误信息"]
					 */
					if (data.success){
						//	刷新列表
						showActivityList();
					}else {
						alert(data.msg);
					}
				}
			})
		}
	}

	//	显示备注信息
	showClueRemarkList = function (){
		//	点击详情页、修改、删除、保存需要局部刷新
		$.ajax({
			url: "workbench/clue/getRemarkListByCid.do",
			data: {
				"clueId": "${clue.id}"
			},
			type: "get",
			success: function (data){
				/*
					data
						[{备注1},{2},{3}]
				 */
				var html = "";
				$.each(data,function (index,clueRemark){
					html += "<div class=\"remarkDiv\" style=\"height: 60px;\">";
					html += "<img title=\"zhangsan\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
					html += "<div style=\"position: relative; top: -40px; left: 40px;\" >";
					html += "<h5 id='h5"+ clueRemark.id +"'>"+ clueRemark.noteContent +"</h5>";
					html += "<font color=\"gray\">线索</font> <font color=\"gray\">-</font> <b>${clue.fullname}${clue.appellation}-${clue.company}</b> <small style=\"color: gray;\" id='small"+ clueRemark.id +"'> "+ (clueRemark.editFlag==0?clueRemark.createTime:clueRemark.editTime) +" 由"+ (clueRemark.editFlag==0?clueRemark.createBy:clueRemark.editBy) +"</small>";
					html += "<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
					html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='editRemark(\""+ clueRemark.id +"\")'><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
					html += "&nbsp;&nbsp;&nbsp;&nbsp;";
					html += "<a class=\"myHref\" href=\"javascript:void(0);\" onclick='deleteRemark(\""+ clueRemark.id +"\")'><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
					html += "</div>";
					html += "</div>";
					html += "</div>";
				})
				$("#clueRemarkDiv").html(html);
			}
		})
	}

	//  将备注信息铺到模态窗口上
	editRemark = function (id){
		//	将 id 保存在隐藏的文本域中
		$("#remarkId").val(id);

		//	拿到 h5 标签中的文本内容
		var $h5noteContent = $("#h5"+id).html();

		//	将 $h5noteContent 的文本内容添加到 修改备注模态窗口 中的文本域
		$("#noteContent").val($h5noteContent);

		//	将信息处理完之后，打开 修改备注的模态窗口
		$("#editRemarkModal").modal("show");
	}

    function deleteRemark(id){

	    if (confirm("亲亲，确定要删除吗？")){

	        $.ajax({
                url: "workbench/clue/deleteRemark.do",
                data: {
                    "id": id
                },
                type: "post",
                success: function (data){

                    if (data.success){
                        showClueRemarkList();
                    }else {
                        alert(data.msg);
                    }
                }
            })

        }
    }
</script>

</head>
<body>

<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>


<!-- 关联市场活动的模态窗口 -->
	<div class="modal fade" id="bundModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="activityName" style="width: 400px;" placeholder="请输入市场活动，支持模糊查询，敲击回车查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="checkbox"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">
							<!--<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>-->
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="boundBtn">关联</button>
				</div>
			</div>
		</div>
	</div>

    <!-- 修改线索的模态窗口 -->


	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${clue.fullname}${clue.appellation} <small>${clue.company}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='workbench/clue/convert.jsp?id=${clue.id}&fullname=${clue.fullname}&appellation=${clue.appellation}&company=${clue.company}&owner=${clue.owner}';"><span class="glyphicon glyphicon-retweet"></span> 转换</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.fullname}${clue.appellation}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.owner}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.company}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.job}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">线索状态</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.state}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clue.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clue.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clue.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${clue.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 100px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${clue.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 40px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<div id="clueRemarkDiv"></div>
		<!-- 备注1
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		-->
		<!-- 备注2
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		-->

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="clueRemark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveClueRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityBody">
						<!--<tr>
							<td>发传单</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>
						<tr>
							<td>发传单</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
							<td>zhangsan</td>
							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
						</tr>-->
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="boundActivityBtn" data-toggle="modal" data-target="#bundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>