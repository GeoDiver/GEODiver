// datatable materialize
!function(e,a,t){var n=function(e,t){"use strict";e.extend(!0,t.defaults,{dom:"<'hiddensearch'f'>tr<'table-footer'lip'>",renderer:"material"}),e.extend(t.ext.classes,{sWrapper:"dataTables_wrapper",sFilterInput:"form-control input-sm",sLengthSelect:"form-control input-sm"}),t.ext.renderer.pageButton.material=function(n,i,r,s,o,l){var d,c,u,b=new t.Api(n),f=n.oClasses,p=n.oLanguage.oPaginate,T=0,m=function(a,t){var i,s,u,g,h=function(a){a.preventDefault(),e(a.currentTarget).hasClass("disabled")||b.page(a.data.action).draw(!1)};for(i=0,s=t.length;s>i;i++)if(g=t[i],e.isArray(g))m(a,g);else{switch(d="",c="",g){case"first":d=p.sFirst,c=g+(o>0?"":" disabled");break;case"previous":d='<i class="material-icons">chevron_left</i>',c=g+(o>0?"":" disabled");break;case"next":d='<i class="material-icons">chevron_right</i>',c=g+(l-1>o?"":" disabled");break;case"last":d=p.sLast,c=g+(l-1>o?"":" disabled")}d&&(u=e("<li>",{"class":f.sPageButton+" "+c,id:0===r&&"string"==typeof g?n.sTableId+"_"+g:null}).append(e("<a>",{href:"#","aria-controls":n.sTableId,"data-dt-idx":T,tabindex:n.iTabIndex}).html(d)).appendTo(a),n.oApi._fnBindAction(u,{action:g},h),T++)}};try{u=e(a.activeElement).data("dt-idx")}catch(g){}m(e(i).empty().html('<ul class="material-pagination"/>').children("ul"),s),u&&e(i).find("[data-dt-idx="+u+"]").focus()},t.TableTools&&(e.extend(!0,t.TableTools.classes,{container:"DTTT btn-group",buttons:{normal:"btn btn-default",disabled:"disabled"},collection:{container:"DTTT_dropdown dropdown-menu",buttons:{normal:"",disabled:"disabled"}},print:{info:"DTTT_print_info"},select:{row:"active"}}),e.extend(!0,t.TableTools.DEFAULTS.oTags,{collection:{container:"ul",button:"li",liner:"a"}}))};"function"==typeof define&&define.amd?define(["jquery","datatables"],n):"object"==typeof exports?n(require("jquery"),require("datatables")):jQuery&&n(jQuery,jQuery.fn.dataTable)}(window,document);

// jquery filedownload
!function(e,o){var t=/[<>&\r\n"']/gm,a={"<":"lt;",">":"gt;","&":"amp;","\r":"#13;","\n":"#10;",'"':"quot;","'":"#39;"};e.extend({fileDownload:function(i,n){function r(){var o=u.cookieValue;"string"==typeof o&&(o=o.toLowerCase());var t=u.cookieName.toLowerCase()+"="+o;if(document.cookie.toLowerCase().indexOf(t)>-1){b.onSuccess(i);var a=u.cookieName+"=; path="+u.cookiePath+"; expires="+new Date(0).toUTCString()+";";return u.cookieDomain&&(a+=" domain="+u.cookieDomain+";"),document.cookie=a,void d(!1)}if(w||k)try{var n=w?w.document:l(k);if(n&&null!==n.body&&n.body.innerHTML.length){var c=!0;if(T&&T.length){var s=e(n.body).contents().first();try{s.length&&s[0]===T[0]&&(c=!1)}catch(p){if(!p||-2146828218!=p.number)throw p;c=!0}}if(c)return void setTimeout(function(){b.onFail(n.body.innerHTML,i),d(!0)},100)}}catch(m){return b.onFail("",i,m),void d(!0)}setTimeout(r,u.checkInterval)}function l(e){var o=e[0].contentWindow||e[0].contentDocument;return o.document&&(o=o.document),o}function d(e){setTimeout(function(){w&&(p&&w.close(),s&&w.focus&&(w.focus(),e&&w.close()))},0)}function c(e){return e.replace(t,function(e){return"&"+a[e]})}var s,p,m,u=e.extend({preparingMessageHtml:null,failMessageHtml:null,androidPostUnsupportedMessageHtml:"Unfortunately your Android browser doesn't support this type of file download. Please try again with a different browser.",dialogOptions:{modal:!0},prepareCallback:function(e){},successCallback:function(e){},failCallback:function(e,o,t){},httpMethod:"GET",data:null,checkInterval:100,cookieName:"fileDownload",cookieValue:"true",cookiePath:"/",cookieDomain:null,popupWindowTitle:"Initiating file download...",encodeHTMLEntities:!0},n),g=new e.Deferred,f=(navigator.userAgent||navigator.vendor||o.opera).toLowerCase();/ip(ad|hone|od)/.test(f)?s=!0:-1!==f.indexOf("android")?p=!0:m=/avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|playbook|silk|iemobile|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(f)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-/i.test(f.substr(0,4));var h=u.httpMethod.toUpperCase();if(p&&"GET"!==h&&u.androidPostUnsupportedMessageHtml)return e().dialog?e("<div>").html(u.androidPostUnsupportedMessageHtml).dialog(u.dialogOptions):alert(u.androidPostUnsupportedMessageHtml),g.reject();var v=null,b={onPrepare:function(o){u.preparingMessageHtml?v=e("<div>").html(u.preparingMessageHtml).dialog(u.dialogOptions):u.prepareCallback&&u.prepareCallback(o)},onSuccess:function(e){v&&v.dialog("close"),u.successCallback(e),g.resolve(e)},onFail:function(o,t,a){v&&v.dialog("close"),u.failMessageHtml&&e("<div>").html(u.failMessageHtml).dialog(u.dialogOptions),u.failCallback(o,t,a),g.reject(o,t)}};b.onPrepare(i),null!==u.data&&"string"!=typeof u.data&&(u.data=e.param(u.data));var k,w,y,T;if("GET"===h){if(null!==u.data){var x=i.indexOf("?");-1!==x?"&"!==i.substring(i.length-1)&&(i+="&"):i+="?",i+=u.data}s||p?(w=o.open(i),w.document.title=u.popupWindowTitle,o.focus()):m?o.location(i):k=e("<iframe>").hide().prop("src",i).appendTo("body")}else{var M="";null!==u.data&&e.each(u.data.replace(/\+/g," ").split("&"),function(){var e=this.split("="),o=e[0];e.shift();var t=e.join("=");e=[o,t];var a=u.encodeHTMLEntities?c(decodeURIComponent(e[0])):decodeURIComponent(e[0]);if(a){var i=u.encodeHTMLEntities?c(decodeURIComponent(e[1])):decodeURIComponent(e[1]);M+='<input type="hidden" name="'+a+'" value="'+i+'" />'}}),m?(T=e("<form>").appendTo("body"),T.hide().prop("method",u.httpMethod).prop("action",i).html(M)):(s?(w=o.open("about:blank"),w.document.title=u.popupWindowTitle,y=w.document,o.focus()):(k=e("<iframe style='display: none' src='about:blank'></iframe>").appendTo("body"),y=l(k)),y.write("<html><head></head><body><form method='"+u.httpMethod+"' action='"+i+"'>"+M+"</form>"+u.popupWindowTitle+"</body></html>"),T=e(y).find("form")),T.submit()}setTimeout(r,u.checkInterval);var C=g.promise();return C.abort=function(){d(),k.remove()},C}})}(jQuery,this);

// geodiver
var GD;GD||(GD={}),function(){GD.setUpValidatorDefaults=function(){$.validator.addMethod("geoDb",function(e){return/^GDS\d\d\d\d?$/.test(e)},"Please enter a valid GEO dataset accession number (in the format GDSxxxx)."),$.validator.setDefaults({errorClass:"invalid",validClass:"valid",errorPlacement:function(e,t){$(t).closest("form").find("label[for='"+t.attr("id")+"']").attr("data-error",e.text())}})},GD.loadGeoDbValidation=function(){"use strict";$("#load_geo_db").validate({rules:{geo_db:{geoDb:!0,required:!0}},submitHandler:function(e){var t=$("input[name=geo_db]").val();$("#model_header_text").text("Loading GEO Dataset: "+t),$("#model_text").text("This should take a few seconds. Please leave this page open"),$("#loading_modal").openModal({dismissible:!1}),$.ajax({type:"POST",url:"/load_geo_db",data:$("#load_geo_db").serialize(),success:function(e){$(".card-action").remove(),$("#results_section").empty(),$(e).insertAfter("#load_geo_card"),$("#geo_db_summary").html(e),$("#geo_db_summary").show(),$(".adv_param_collapsible").collapsible(),$("input:radio[name=factor]:first").attr("checked",!0),$("#"+$("input:radio[name=factor]:first").attr("id")+"_select").show(),GD.addFactorToggle(),$("select").material_select(),GD.addDataSetInfo(),GD.analyseValidation(),$("#loading_modal").closeModal()},error:function(e,t){GD.ajaxError(e,t)}})}})},GD.analyseValidation=function(){"use strict";$("#analyse").validate({rules:{},submitHandler:function(e){var t=$("input[name=geo_db]").val();$("#model_header_text").text("Analysing GEO Dataset: "+t),$("#model_text").text("This should take a few minutes. Please leave this page open"),$("#loading_modal").openModal({dismissible:!1}),$.ajax({type:"POST",url:"/analyse",data:$("#analyse").serialize(),success:function(e){$("#results_section").html(e),$("#results_section").show(),$("#results_tabs").tabs(),GD.createPlots(),$(".materialboxed").materialbox(),$("#loading_modal").closeModal()},error:function(e,t){GD.ajaxError(e,t)}})}})},GD.geneExpressionAjax=function(e,t){$("#model_header_text").text("Loading Graphics for Gene: "+t),$("#model_text").text("This should take a few seconds. Please leave this page open"),$("#loading_modal").openModal({dismissible:!1});var a=e.closest(".results_card").data("results_id"),o=e.closest(".results_card").data("geo_db");$.ajax({type:"POST",url:"/gene_expression_url",data:{gene_id:t,result_id:a,geo_db:o},success:function(a){e.addClass("parent"),e.after('<tr class="child" id="'+t+'ChildRow"><td colspan="8"><div id="'+t+'Plot"></div></td></tr>'),GD.createExpressionPlot(a,t),$("#loading_modal").closeModal()},error:function(e,t){GD.ajaxError(e,t)}})},GD.interactionNetworkAjax=function(e,t){$("#model_header_text").text("Loading Graphics for GeneSet: "+t),$("#model_text").text("This should take a few seconds. Please leave this page open"),$("#loading_modal").openModal({dismissible:!1});var a=e.closest(".results_card").data("results_id"),o=e.closest(".results_card").data("geo_db");$.ajax({type:"POST",url:"/interaction",data:{path_id:t,result_id:a,geo_db:o},success:function(t){e.addClass("parent"),e.after(t),$("#loading_modal").closeModal()},error:function(e,t){GD.ajaxError(e,t)}})},GD.ajaxError=function(e,t){var a;500==e.status||400==e.status?(a=e.responseText,$("#results_section").show(),$("#results_section").html(a),$("#loading_modal").closeModal()):(a=e.responseText,$("#results_section").show(),$("#results_section").html("There seems to be an unidentified Error."),$("#loading_modal").closeModal())},GD.loadPcRedrawValidation=function(){$("#pca_redraw").validate({rules:{},submitHandler:function(e,t){t.preventDefault(),$("#principle_plot").empty();var a=$("select[name=PCoption1]").val(),o=$("select[name=PCoption2]").val(),l=$("select[name=PCoption3]").val(),i=$("#overview").data("overview-json");$.getJSON(i,function(e){GD.createPCAScatterPlot(e.pcdata,a,o,l)})}})},GD.createPlots=function(){var e=$("#overview").data("overview-json");$.getJSON(e,function(e){pcaPlot=GD.createPCAPLOT(e.pc.cumVar,e.pc.expVar,e.pc.pcnames),pcaScatterPlot=GD.createPCAScatterPlot(e.pcdata,"PC1","PC2","PC3"),GD.initialiatizePcaScatterPlot(e.pc.pcnames),$("select").material_select()});var t=$("#DGEA").data("dgea-json");$.getJSON(t,function(e){volcanoPlot=GD.createVolcanoPlot(e.vol.logFC,e.vol.pVal,e.vol.genes),GD.initializeToptable(e.tops,"dgea-top-table","dgea-top-table-wrapper")});var a=$("#GSEA").data("gsea-json");$.getJSON(a,function(e){GD.initializeToptable(e.tops,"gsea-top-table","gsea-top-table-wrapper")}),window.onresize=function(){Plotly.Plots.resize(pcaPlot),Plotly.Plots.resize(volcanoPlot),Plotly.Plots.resize(pcaScatterPlot)}},GD.createPCAScatterPlot=function(e,t,a,o){var l,i,n,r,s,d,c;return"undefined"==typeof o?(l={x:e[t+".Group1"],y:e[a+".Group1"],text:e.Group1,type:"scatter",mode:"markers",name:"Group1",marker:{symbol:"circle"}},i={x:e[t+".Group2"],y:e[a+".Group2"],text:e.Group2,type:"scatter",mode:"markers",name:"Group2",marker:{symbol:"square"}},n=[l,i],r={xaxis:{title:t},yaxis:{title:a}},s=100,d=Plotly.d3.select("#principle_plot").style({width:s+"%","margin-left":(100-s)/2+"%"}),c=d.node(),Plotly.newPlot(c,n,r),c):(l={x:e[t+".Group1"],y:e[a+".Group1"],z:e[o+".Group1"],text:e.Group1,type:"scatter3d",mode:"markers",name:"Group1",marker:{symbol:"circle"}},i={x:e[t+".Group2"],y:e[a+".Group2"],z:e[o+".Group2"],text:e.Group2,type:"scatter3d",mode:"markers",name:"Group2",marker:{symbol:"square"}},n=[l,i],r={xaxis:{title:t},yaxis:{title:a},zaxis:{title:o}},s=100,d=Plotly.d3.select("#principle_plot").style({width:s+"%","margin-left":(100-s)/2+"%"}),c=d.node(),Plotly.newPlot(c,n,r),c)},GD.createPCAPLOT=function(e,t,a){var o={x:a,y:e,type:"scatter",name:"Cumulative PCA"},l={x:a,y:t,type:"scatter",name:"PCA"},i=[o,l],n={legend:{x:0,y:100,traceorder:"normal"}},r=100,s=Plotly.d3.select("#PCA_plot").style({width:r+"%","margin-left":(100-r)/2+"%"}),d=s.node();return Plotly.newPlot(d,i,n),d},GD.createVolcanoPlot=function(e,t,a){var o={x:e,y:t,text:a,mode:"markers",type:"scatter",name:"volcano_plot",marker:{size:7.5}},l=[o],i={xaxis:{title:"Log 2 Fold Change"},yaxis:{title:"-Log10(P Value)"},hovermode:"closest"},n=100,r=Plotly.d3.select("#volcano_plot").style({width:n+"%","margin-left":(100-n)/2+"%"}),s=r.node();return Plotly.newPlot(s,l,i),s},GD.createExpressionPlot=function(e,t){var a={x:e.group1.x,y:e.group1.y,type:"bar",name:"Group 1"},o={x:e.group2.x,y:e.group2.y,type:"bar",name:"Group 2"},l=[a,o],i={barmode:"group",xaxis:{title:"Sample",tickangle:-40,position:-.5},yaxis:{title:"Expression"}},n=100,r=Plotly.d3.select("#"+t+"Plot").style({width:n+"%","margin-left":(100-n)/2+"%"}),s=r.node();Plotly.newPlot(s,l,i),window.onresize=function(){Plotly.Plots.resize(s)}},GD.initializeToptable=function(e,t,a){e=GD.addPlotIconToTopTable(e);$("#"+t).dataTable({oLanguage:{sStripClasses:"",sSearch:"",sSearchPlaceholder:"Enter Keywords Here",sInfo:"_START_ -_END_ of _TOTAL_",sLengthMenu:'<span>Rows per page:</span><select class="browser-default"><option value="10">10</option><option value="20">20</option><option value="30">30</option><option value="40">40</option><option value="50">50</option><option value="-1">All</option></select></div>'},data:e,order:[[5,"asc"]],bAutoWidth:!1});GD.makePlotIconClickable(a),$("#"+a).on("click",".search-toggle",function(){"none"==$(".hiddensearch").css("display")?$(".hiddensearch").slideDown():$(".hiddensearch").slideUp()}),$("#"+a).on("click",".download-top-table",function(){return $("#model_header_text").text("Creating Download Link"),$("#model_text").text("This should take a few seconds. Please leave this page open"),$("#loading_modal").openModal({dismissible:!1}),$.fileDownload($(this).attr("href"),{successCallback:function(e){$("#loading_modal").closeModal()},failCallback:function(e,t){$("#loading_modal").closeModal()}}),!1})},GD.addPlotIconToTopTable=function(e){return $.each(e,function(e,t){t.push('<i class="material-icons child-row-chart light-blue-text text-darken-3">insert_chart</i>')}),e},GD.makePlotIconClickable=function(e){$("#"+e).on("click",".child-row-chart",function(){var t=$(this).closest("tr"),a=t.children("td:first").text();$("#"+a+"ChildRow").length?$("#"+a+"ChildRow").remove():"dgea-top-table-wrapper"===e?GD.geneExpressionAjax(t,a):"gsea-top-table-wrapper"===e&&GD.interactionNetworkAjax(t,a)})},GD.initialiatizePcaScatterPlot=function(e){$.each(e,function(e,t){$("#PCoption1").append($("<option></option>").attr("value",t).text(t)),$("#PCoption2").append($("<option></option>").attr("value",t).text(t)),$("#PCoption3").append($("<option></option>").attr("value",t).text(t))}),GD.loadPcRedrawValidation()},GD.addFactorToggle=function(){$("input:radio[name=factor]").click(function(){var e="#"+$(this).attr("id")+"_select";"#"+$(".select_factors:visible").attr("id")!==e&&($(".select_factors").hide(),$(e).show())})},GD.addDataSetInfo=function(){var e=$("input[name=geo_db]").val(),t="GeoDiver/DBs/"+e+".json";$.getJSON(t,function(e){$("#dataset_accession").text(e.Accession),$("#dataset_title").text(e.Title),$("#dataset_summary").text(e.Description),$("#dataset_organism").text(e.Sample_Organism),$("#dataset_summary").text(e.Description),$("#dataset_citation").text(e.Reference)})},GD.addUserDropDown=function(){$(".dropdown-button").dropdown({inDuration:300,outDuration:225,hover:!0,belowOrigin:!0,alignment:"right"})}}(),function(e){e(function(){e(".button-collapse").sideNav(),e(".parallax").parallax(),e("select").material_select(),GD.setUpValidatorDefaults(),GD.loadGeoDbValidation(),GD.addUserDropDown()})}(jQuery);