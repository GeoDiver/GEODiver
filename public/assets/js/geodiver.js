/*
    GD - GeoDiver's JavaScript module

    Define a global GD (acronym for GeoDiver) object containing all
    GD associated methods:
*/

// define global GD object
var GD;
if (!GD) {
    GD = {};
}

// GD module
(function() {
    GD.setUpValidatorDefaults = function() {
        $.validator.addMethod('geoDb', function(value) {
            return /^G[DS][SE]\d\d?\d?\d?\d?$/i.test(value);
        }, 'Please enter a valid GEO dataset accession number (in the format GDSxxxx).');

        $.validator.addMethod('checkIfGeoExists', function(value) {
            var doesNotExist = [1, 2, 3, 4, 7, 8, 9, 11, 13, 14, 22, 24, 25, 27, 28, 29, 32, 41, 42, 43, 44, 54, 55, 57, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 79, 81, 82, 83, 84, 87, 89, 90, 97, 98, 101, 102, 103, 107, 109, 114, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 136, 137, 138, 139, 140, 141, 142, 143, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 159, 163, 165, 166, 173, 175, 176, 178, 179, 180, 184, 185, 188, 189, 190, 191, 193, 194, 195, 196, 197, 202, 204, 206, 207, 208, 209, 210, 211, 212, 216, 217, 218, 219, 220, 221, 226, 228, 229, 230, 231, 235, 237, 257, 260, 263, 269, 271, 273, 275, 277, 284, 286, 327, 328, 330, 331, 333, 334, 335, 336, 338, 340, 341, 342, 343, 347, 348, 349, 350, 351, 357, 361, 363, 365, 370, 371, 372, 373, 375, 376, 377, 379, 380, 381, 382, 383, 391, 392, 393, 396, 397, 398, 403, 405, 406, 407, 408, 419, 442, 445, 447, 448, 450, 452, 454, 455, 456, 457, 458, 459, 460, 461, 462, 464, 465, 466, 467, 474, 475, 482, 485, 489, 490, 492, 496, 497, 500, 503, 506, 512, 523, 530, 537, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 558, 566, 569, 570, 571, 572, 573, 581, 585, 590, 593, 594, 595, 597, 601, 603, 613, 616, 619, 620, 626, 628, 629, 633, 634, 642, 643, 644, 645, 646, 650, 655, 669, 673, 674, 675, 676, 678, 688, 689, 691, 692, 693, 697, 706, 712, 713, 714, 715, 716, 727, 729, 730, 733, 736, 741, 745, 746, 747, 749, 753, 754, 757, 758, 760, 762, 763, 764, 774, 783, 784, 789, 792, 793, 795, 796, 797, 798, 800, 801, 802, 803, 804, 805, 815, 816, 818, 819, 821, 822, 824, 839, 842, 850, 861, 864, 865, 875, 876, 886, 888, 889, 895, 896, 897, 898, 903, 904, 914, 921, 923, 924, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 941, 950, 952, 957, 973, 974, 975, 978, 979, 980, 985, 986, 990, 1000, 1004, 1005, 1006, 1007, 1008, 1016, 1021, 1024, 1025, 1026, 1029, 1031, 1034, 1035, 1040, 1041, 1042, 1045, 1046, 1052, 1060, 1061, 1066, 1069, 1070, 1075, 1081, 1082, 1086, 1087, 1089, 1090, 1091, 1092, 1097, 1098, 1100, 1101, 1102, 1104, 1105, 1114, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144, 1145, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162, 1163, 1164, 1165, 1166, 1167, 1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192, 1193, 1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201, 1202, 1203, 1206, 1207, 1208, 1216, 1217, 1218, 1223, 1224, 1229, 1242, 1246, 1259, 1260, 1262, 1267, 1268, 1281, 1283, 1291, 1296, 1297, 1308, 1322, 1337, 1341, 1345, 1355, 1356, 1358, 1364, 1368, 1370, 1377, 1378, 1386, 1387, 1391, 1403, 1410, 1415, 1416, 1417, 1418, 1420, 1425, 1426, 1428, 1430, 1432, 1433, 1437, 1441, 1454, 1457, 1458, 1459, 1460, 1461, 1462, 1463, 1470, 1471, 1482, 1483, 1487, 1493, 1506, 1508, 1524, 1525, 1535, 1536, 1537, 1538, 1539, 1540, 1554, 1556, 1558, 1561, 1564, 1566, 1567, 1569, 1570, 1573, 1574, 1575, 1576, 1577, 1578, 1586, 1587, 1588, 1589, 1590, 1591, 1592, 1594, 1595, 1598, 1601, 1602, 1603, 1605, 1613, 1614, 1619, 1623, 1624, 1625, 1628, 1639, 1643, 1656, 1659, 1668, 1669, 1671, 1680, 1682, 1683, 1698, 1708, 1720, 1721, 1722, 1725, 1737, 1738, 1740, 1742, 1749, 1751, 1754, 1755, 1762, 1769, 1770, 1775, 1781, 1782, 1787, 1789, 1790, 1811, 1814, 1817, 1818, 1819, 1820, 1822, 1823, 1828, 1829, 1831, 1834, 1856, 1859, 1860, 1861, 1863, 1866, 1867, 1868, 1876, 1885, 1888, 1889, 1893, 1894, 1895, 1896, 1897, 1898, 1899, 1900, 1907, 1909, 1918, 1919, 1927, 1930, 1935, 1944, 1945, 1946, 1947, 1948, 1949, 1950, 1953, 1958, 1961, 1966, 1967, 1969, 1970, 1971, 1991, 1992, 1994, 1996, 1997, 1998, 1999, 2000, 2017, 2022, 2033, 2059, 2062, 2067, 2068, 2075, 2076, 2085, 2108, 2116, 2117, 2121, 2122, 2127, 2128, 2129, 2130, 2131, 2133, 2137, 2140, 2148, 2155, 2166, 2198, 2199, 2210, 2220, 2238, 2247, 2252, 2256, 2257, 2262, 2271, 2273, 2275, 2278, 2279, 2280, 2286, 2290, 2293, 2296, 2299, 2305, 2306, 2315, 2337, 2340, 2345, 2348, 2357, 2369, 2376, 2392, 2393, 2394, 2401, 2402, 2403, 2404, 2405, 2407, 2409, 2435, 2436, 2441, 2449, 2450, 2458, 2459, 2465, 2467, 2473, 2476, 2488, 2492, 2500, 2503, 2505, 2506, 2507, 2510, 2512, 2527, 2538, 2539, 2541, 2543, 2544, 2551, 2557, 2560, 2568, 2574, 2620, 2621, 2634, 2644, 2645, 2670, 2679, 2689, 2690, 2692, 2711, 2714, 2726, 2776, 2792, 2793, 2796, 2797, 2798, 2799, 2800, 2801, 2806, 2807, 2828, 2829, 2836, 2837, 2839, 2844, 2845, 2849, 2871, 2888, 2890, 2891, 2894, 2896, 2897, 2898, 2899, 2900, 2907, 2942, 2943, 2979, 2985, 2986, 2992, 2994, 2995, 2997, 3013, 3015, 3016, 3019, 3020, 3021, 3022, 3024, 3026, 3053, 3055, 3063, 3065, 3066, 3067, 3075, 3076, 3090, 3093, 3094, 3098, 3146, 3161, 3164, 3165, 3166, 3167, 3168, 3169, 3170, 3185, 3200, 3201, 3202, 3204, 3205, 3206, 3208, 3212, 3213, 3214, 3219, 3236, 3237, 3246, 3247, 3248, 3249, 3250, 3261, 3263, 3264, 3265, 3266, 3269, 3270, 3271, 3272, 3273, 3275, 3276, 3277, 3278, 3279, 3280, 3286, 3301, 3302, 3303, 3304, 3307, 3314, 3317, 3327, 3328, 3335, 3336, 3337, 3338, 3339, 3340, 3347, 3348, 3359, 3372, 3377, 3378, 3380, 3381, 3389, 3390, 3391, 3409, 3443, 3449, 3450, 3451, 3457, 3458, 3460, 3541, 3542, 3543, 3546, 3563, 3565, 3569, 3584, 3585, 3586, 3587, 3588, 3589, 3590, 3611, 3614, 3617, 3645, 3650, 3651, 3652, 3693, 3695, 3708, 3731, 3760, 3778, 3817, 3821, 3822, 3828, 3845, 3877, 3878, 3879, 3937, 3947, 3967, 3968, 3969, 3970, 3971, 3979, 3994, 4020, 4022, 4031, 4033, 4044, 4049, 4060, 4062, 4068, 4072, 4073, 4075, 4076, 4086, 4087, 4097, 4098, 4111, 4112, 4117, 4122, 4126, 4127, 4139, 4183, 4184, 4187, 4192, 4197, 4241, 4292, 4293, 4405, 4529, 4530, 4561, 4603, 4604, 4605, 4616, 4623, 4624, 4625, 4626, 4627, 4628, 4629, 4630, 4631, 4632, 4633, 4634, 4635, 4636, 4637, 4638, 4639, 4640, 4641, 4642, 4643, 4644, 4645, 4646, 4647, 4648, 4649, 4650, 4651, 4652, 4653, 4654, 4655, 4656, 4657, 4658, 4659, 4660, 4661, 4662, 4663, 4666, 4667, 4668, 4670, 4671, 4672, 4673, 4674, 4675, 4676, 4677, 4678, 4679, 4680, 4681, 4682, 4683, 4684, 4685, 4686, 4687, 4688, 4689, 4690, 4691, 4692, 4693, 4694, 4695, 4696, 4697, 4698, 4699, 4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709, 4710, 4711, 4712, 4713, 4714, 4715, 4716, 4717, 4720, 4721, 4722, 4723, 4724, 4725, 4726, 4727, 4728, 4729, 4730, 4731, 4732, 4733, 4734, 4735, 4736, 4737, 4738, 4739, 4740, 4741, 4742, 4743, 4744, 4745, 4746, 4747, 4748, 4749, 4750, 4751, 4752, 4753, 4789, 4790, 4792, 4793, 4860, 4861, 4862, 4863, 4864, 4865, 4866, 4867, 4868, 4869, 4870, 4871, 4872, 4873, 4874, 4875, 4878, 4888, 4889, 4890, 4905, 4906, 4907, 4908, 4909, 4918, 4919, 4920, 4921, 4922, 4923, 4924, 4925, 4927, 4932, 4933, 4934, 4935, 4938, 4939, 4942, 4945, 4946, 4948, 4951, 4952, 4963, 4975, 4976, 4977, 4982, 4995, 4996, 4997, 4998, 4999, 5000, 5001, 5002, 5003, 5004, 5005, 5011, 5027, 5035, 5036, 5038, 5039, 5042, 5043, 5044, 5068, 5069, 5081, 135, 1330, 3666, 3727, 3796, 3890, 3897, 3922, 3946, 3957, 3986, 4807, 5021, 5037];
            if (value.length > 3) {
                if ($.inArray(parseInt(value.substring(3)), doesNotExist) !== -1 && /^GDS\d\d?\d?\d?$/i.test(value)) {
                    return false;
                } else { return true; }
            } else { return true; }
        }, 'This GEO dataset accession number does not exist.');

        $.validator.setDefaults({
            errorClass: 'invalid',
            validClass: "valid",
            errorPlacement: function(error, element) {
                $(element)
                    .closest("form")
                    .find("label[for='" + element.attr("id") + "']")
                    .attr('data-error', error.text());
            },
        });
    };

    ///// AJAXs

    GD.loadGeoDbValidation = function() {
        'use strict';
        $('#load_geo_db').validate({
            rules: {
                geo_db: {
                    geoDb: true,
                    checkIfGeoExists: true,
                    required: true
                },
            },
            submitHandler: function() {
                $('.card-action').remove();
                $('#results_section').empty();
                var geo_db = $('input[name=geo_db]').val().toUpperCase();
                $('#modal_header_text').text('Loading GEO Dataset: ' + geo_db);
                $('#modal_text').text('This should take a few seconds. Please leave this page open');
                $('#loading_modal').modal({ dismissible: false });
                $('#loading_modal').modal('open');
                $.ajax({
                    type: 'POST',
                    url: '/load_geo_db',
                    data: $('#load_geo_db').serialize(),
                    success: function(response) {
                        $(response).insertAfter("#load_geo_card");
                        $('#geo_db_summary').html(response);
                        $('#geo_db_summary').show();
                        $('.adv_param_collapsible').collapsible();
                        $("input:radio[name=factor]:first").attr('checked', true);
                        $('#' + $("input:radio[name=factor]:first").attr('id') + '_select').show();
                        $('#adv_params_btn').click(function() {
                            if (!$('#adv_params_params_tabs').hasClass('tabs_initialised')) {
                                setTimeout(
                                    function() {
                                        $('#adv_params_params_tabs').tabs();
                                        $('#adv_params_params_tabs').addClass('tabs_initialised');
                                    }, 1);
                            }
                        });
                        $('select[name="groupa[]"]').on('change', function() {
                            if ($.isEmptyObject($('select[name="groupa[]"]:enabled').val())) {
                                $('#groupa_params').attr('data-tooltip', 'This is Group A');
                                $('#groupa_params').tooltip({ delay: 50 });
                            } else {
                                $('#groupa_params').attr('data-tooltip', 'Group A: ' + $('select[name="groupa[]"]:enabled').val().join(", "));
                                $('#groupa_params').tooltip({ delay: 50 });
                            }
                        });
                        $('select[name="groupb[]"]').on('change', function() {
                            if ($.isEmptyObject($('select[name="groupb[]"]:enabled').val())) {
                                $('#groupb_params').attr('data-tooltip', 'This is Group B');
                                $('#groupb_params').tooltip({ delay: 50 });
                            } else {
                                $('#groupb_params').attr('data-tooltip', 'Group B: ' + $('select[name="groupb[]"]:enabled').val().join(", "));
                                $('#groupb_params').tooltip({ delay: 50 });
                            }
                        });
                        GD.ensureOnlyOneSelectOption();
                        GD.addAdvParamLogic();
                        GD.addFactorToggle();
                        $('select').material_select();
                        $('.tooltipped').tooltip();
                        GD.addGeoDbInfo($('input[name=geo_db]').val());
                        GD.analyseValidation();
                        $('#loading_modal').modal('close');
                    },
                    error: function(e, status) {
                        GD.ajaxError(e, status);
                    }
                });
            }
        });
    };

    GD.exemplar_results = function() {
        $('#exemplar_result').click(function() {
            $('input[name=geo_db]').val('GDS724');
            $('#load_geo_db').submit();
        });
    };

    GD.analyseValidation = function() {
        'use strict';
        $('#analyse').validate({
            rules: {},
            submitHandler: function() {
                // Manually check if groupa / groupb is empty
                if ($.isEmptyObject($('select[name="groupa[]"]:enabled').val()) || $.isEmptyObject($('select[name="groupb[]"]:enabled').val())) {
                    $('.select_factors_validations').text('Please select the factors in the two groups to analyse.');
                    return false;
                }
                $('.select_factors_validations').text('');
                $('#results_section').empty();
                var geo_db = $('input[name=geo_db]').val().toUpperCase();
                $('input[name="dgea_cluster_by_genes"]').val($('input[name="dgea_cluster_by_genes"]').is(':checked'));
                $('input[name="dgea_cluster_by_samples"]').val($('input[name="dgea_cluster_by_samples"]').is(':checked'));
                $('input[name="gsea_cluster_by_genes"]').val($('input[name="gsea_cluster_by_genes"]').is(':checked'));
                $('input[name="gsea_cluster_by_samples"]').val($('input[name="gsea_cluster_by_samples"]').is(':checked'));
                $('#modal_header_text').text('Analysing GEO Dataset: ' + geo_db);
                $('#modal_text').text('This should take a few minutes. Please leave this page open');
                $('#loading_modal').modal({ dismissible: false });
                $('#loading_modal').modal('open');
                $.ajax({
                    type: 'POST',
                    url: '/analyse',
                    data: $('#analyse').serialize(),
                    success: function(response) {
                        $('#results_section').show();
                        $('#results_section').html(response).imagesLoaded().then(function() {
                            $('#pca_tabs').tabs(); // init material tabs
                            $('#results_tabs').tabs(); // init material tabs
                            GD.createPlots();
                            $('.materialboxed').materialbox(); // init materialbox
                            $('.select_factors input.select-dropdown').removeAttr('disabled');
                            GD.download_all_results();
                            GD.delete_result();
                            GD.share_result();
                            GD.show_GeoDB_modal();
                            GD.remove_share();
                            $('#loading_modal').modal('close');
                            $('html, body').animate({
                                scrollTop: $('#results_section').offset().top
                            });
                        });
                    },
                    error: function(e, status) {
                        GD.ajaxError(e, status);
                    }
                });
                return undefined;
            }
        });
    };

    GD.geneExpressionAjax = function(currentRow, geneId) {
        $('#modal_header_text').text('Loading Graphics for Gene: ' + geneId);
        $('#modal_text').text('This should take a few seconds. Please leave this page open');
        $('#loading_modal').modal({ dismissible: false });
        $('#loading_modal').modal('open');
        var resultId = currentRow.closest('.results_card').data('result');
        var geoDb = currentRow.closest('.results_card').data('geodb');
        var user = currentRow.closest('.results_card').data('user');
        $.ajax({
            type: 'POST',
            url: '/gene_expression_graph',
            data: { gene_id: geneId, result_id: resultId, geo_db: geoDb, user: user },
            success: function(response) {
                currentRow.addClass('parent');
                currentRow.after('<tr class="child" id="' + geneId + 'ChildRow"><td colspan="8"><div id="' + geneId + 'Plot"></div></td></tr>');
                GD.createExpressionPlot(response, geneId);
                $('#loading_modal').modal('close');
            },
            error: function(e, status) {
                GD.ajaxError(e, status);
            }
        });
    };

    GD.interactionNetworkAjax = function(currentRow, pathId) {
        $('#modal_header_text').text('Loading Graphics for GeneSet: ' + pathId);
        $('#modal_text').text('This should take a few seconds. Please leave this page open');
        $('#loading_modal').modal({ dismissible: false });
        $('#loading_modal').modal('open');
        var resultId = currentRow.closest('.results_card').data('result');
        var geoDb = currentRow.closest('.results_card').data('geodb');
        var user = currentRow.closest('.results_card').data('user');
        $.ajax({
            type: 'POST',
            url: '/interaction_image',
            data: { path_id: pathId, result_id: resultId, geo_db: geoDb, user: user },
            success: function(response) {
                currentRow.addClass('parent');
                currentRow.after(response);
                $('#loading_modal').modal('close');
            },
            error: function(e, status) {
                GD.ajaxError(e, status);
            }
        });
    };

    GD.ajaxError = function(e, status) {
        var errorMessage;
        if (e.status == 500 || e.status == 400) {
            errorMessage = e.responseText;
            $('#results_section').show();
            $('#results_section').html(errorMessage);
            $('#loading_modal').modal('close'); // remove progress notification
        } else {
            errorMessage = e.responseText;
            $('#results_section').show();
            $('#results_section').html('<div class="card red lighten-2" role="alert"><div class="card-content white-text"><h3>Oops! GeoDiver is Drowning!</h3><p style="font-size: 1.5rem"><strong>Apologies, there was an error with your request. Please try again.</strong></p><p>Error Message:' + errorMessage + ' The server responded with the status code: ' + String(e.status) + '. Please refresh the page and try again.</p><p>If the error persists, please contact the administrator.</p></div></div>');
            $('#loading_modal').modal('close'); // remove progress notification
        }
    };

    GD.loadPcRedrawValidation = function() {
        $('#pca3d_redraw').validate({
            rules: {},
            submitHandler: function(form, event) {
                // Manually check if groupa / groupb is empty
                if ($.isEmptyObject($('select[name="PC3doption1"]').val()) || $.isEmptyObject($('select[name="PC3doption2"]').val()) || $.isEmptyObject($('select[name="PC3doption3"]').val())) {
                    $('.select_pc3_validations').text('Please select the Pricipal Components to analyse.');
                    return false;
                }
                // Manually check if PC2dOption1 == PC2dOption2
                if (($('select[name="PC3doption1"]').val() === $('select[name="PC3doption2"]').val()) ||
                    ($('select[name="PC3doption3"]').val() === $('select[name="PC3doption2"]').val()) ||
                    ($('select[name="PC3doption1"]').val() === $('select[name="PC3doption3"]').val())) {
                    $('.select_pc3_validations').text('Please select different principal components to analyse.');
                    return false;
                }
                $('.select_pc3_validations').text('');
                event.preventDefault(); // because we're not submitting at all
                $('#pca3d_plot').empty();
                var x = $('select[name=PC3doption1]').val();
                var y = $('select[name=PC3doption2]').val();
                var z = $('select[name=PC3doption3]').val();
                var jsonFile = $('#overview').data("overview-json");
                $.getJSON(jsonFile, function(json) {
                    GD.create3dPCAScatterPlot(json.pcdata, x, y, z);
                });
                return undefined;
            }
        });
        $('#pca2d_redraw').validate({
            rules: {},
            submitHandler: function(form, event) {
                // Manually check if PC2dOption1 / PC2dOption2 is empty
                if ($.isEmptyObject($('select[name="PC2doption1"]').val()) || $.isEmptyObject($('select[name="PC2doption2"]').val())) {
                    $('.select_pc2_validations').text('Please select the principal components to analyse.');
                    return false;
                }
                // Manually check if PC2dOption1 == PC2dOption2
                if ($('select[name="PC2doption1"]').val() === $('select[name="PC2doption2"]').val()) {
                    $('.select_pc2_validations').text('Please select different principal components to analyse.');
                    return false;
                }

                $('.select_pc2_validations').text('');
                event.preventDefault(); // because we're not submitting at all
                $("#pca2d_plot").empty();
                var x = $('select[name=PC2doption1]').val();
                var y = $('select[name=PC2doption2]').val();
                var jsonFile = $('#overview').data("overview-json");
                $.getJSON(jsonFile, function(json) {
                    GD.create2dPCAScatterPlot(json.pcdata, x, y);
                });
                return undefined;
            }
        });
    };


    ///// PLOTS

    GD.createPlots = function() {
        var jsonFile = $('#overview').data("overview-json");
        $.getJSON(jsonFile, function(json) {
            GD.pcaPlot = GD.createPCAPLOT(json.pc.cumVar, json.pc.expVar, json.pc.pcnames);
            GD.pca2dScatterPlot = GD.create2dPCAScatterPlot(json.pcdata, 'PC1', 'PC2');
            GD.pca3dScatterPlot = GD.create3dPCAScatterPlot(json.pcdata, 'PC1', 'PC2', 'PC3');

            GD.initialiatizePcaScatterPlot(json.pc.pcnames);
            $('select').material_select();
        });

        $('#pca_tabs').on('click', '.tab a', function() {
            if ($(this).attr('href') === '#pca2d') {
                Plotly.Plots.resize(GD.pca2dScatterPlot);
            } else {
                Plotly.Plots.resize(GD.pca3dScatterPlot);
            }
        });

        var dgeaJsonFile = $('#DGEA').data("dgea-json");
        $.getJSON(dgeaJsonFile, function(json) {
            GD.volcanoPlot = GD.createVolcanoPlot(json.vol.logFC, json.vol.pVal, json.vol.genes);
            GD.initializeToptable(json.tops, 'dgea-top-table', 'dgea-top-table-wrapper');
        });

        var gseaJsonFile = $('#GSEA').data("gsea-json");
        $.getJSON(gseaJsonFile, function(json) {
            GD.initializeToptable(json.tops, 'gsea-top-table', 'gsea-top-table-wrapper');
        });
        window.addEventListener('resize', function() {
            /** global: Plotly */
            Plotly.Plots.resize(GD.pcaPlot);
            Plotly.Plots.resize(GD.volcanoPlot);
            Plotly.Plots.resize(GD.pca2dScatterPlot);
            Plotly.Plots.resize(GD.pca3dScatterPlot);
        });
        GD.addGraphTooltips();
    };

    GD.create2dPCAScatterPlot = function(pcdata, x, y) {
        var group1, group2, group1_name, group2_name, data, layout, parentWidth, PCAplotGd3, pcaPlot;
        group1_name = pcdata.group1[0];
        group2_name = pcdata.group2[0];
        group1 = { x: pcdata[x + '.' + group1_name], y: pcdata[y + '.' + group1_name], text: pcdata.Group1, type: 'scatter', mode: 'markers', name: group1_name, marker: { symbol: 'circle' } };
        group2 = { x: pcdata[x + '.' + group2_name], y: pcdata[y + '.' + group2_name], text: pcdata.Group2, type: 'scatter', mode: 'markers', name: group2_name, marker: { symbol: 'square' } };
        data = [group1, group2];
        layout = { xaxis: { title: x }, yaxis: { title: y }, hovermode: 'closest' };

        parentWidth = 100;
        PCAplotGd3 = Plotly.d3.select('#pca2d_plot')
            .style({
                width: parentWidth + '%',
                'margin-left': (100 - parentWidth) / 2 + '%'
            });
        pcaPlot = PCAplotGd3.node();

        Plotly.newPlot(pcaPlot, data, layout);
        return pcaPlot;
    };

    GD.create3dPCAScatterPlot = function(pcdata, x, y, z) {
        var group1, group2, group1_name, group2_name, data, layout, parentWidth, PCAplotGd3, pcaPlot;
        group1_name = pcdata.group1[0];
        group2_name = pcdata.group2[0];
        group1 = { x: pcdata[x + '.' + group1_name], y: pcdata[y + '.' + group1_name], z: pcdata[z + '.' + group1_name], text: pcdata.Group1, type: 'scatter3d', mode: 'markers', name: group1_name, marker: { symbol: 'circle' } };
        group2 = { x: pcdata[x + '.' + group2_name], y: pcdata[y + '.' + group2_name], z: pcdata[z + '.' + group2_name], text: pcdata.Group2, type: 'scatter3d', mode: 'markers', name: group2_name, marker: { symbol: 'square' } };
        data = [group1, group2];
        layout = { scene: { xaxis: { title: x }, yaxis: { title: y }, zaxis: { title: z } }, hovermode: 'closest' };

        parentWidth = 100;
        PCAplotGd3 = Plotly.d3.select('#pca3d_plot')
            .style({
                width: parentWidth + '%',
                'margin-left': (100 - parentWidth) / 2 + '%'
            });
        pcaPlot = PCAplotGd3.node();
        Plotly.newPlot(pcaPlot, data, layout);
        return pcaPlot;
    };

    GD.createPCAPLOT = function(cumVar, expVar, pcaNames) {
        var CumulativePCA = { x: pcaNames, y: cumVar, type: 'scatter', name: 'Cumulative PCA' };
        var PCA = { x: pcaNames, y: expVar, type: 'scatter', name: 'PCA' };
        var data = [CumulativePCA, PCA];
        var layout = { legend: { x: 0, y: 100, traceorder: 'normal' } };

        var parentWidth = 100;
        var PCAplotGd3 = Plotly.d3.select('#PCA_plot')
            .style({
                width: parentWidth + '%',
                'margin-left': (100 - parentWidth) / 2 + '%'
            });
        var pcaPlot = PCAplotGd3.node();
        Plotly.newPlot(pcaPlot, data, layout);
        return pcaPlot;
    };

    //
    GD.createVolcanoPlot = function(xValues, yValues, genes) {
        var trace1 = { x: xValues, y: yValues, text: genes, mode: 'markers', type: 'scatter', name: 'volcano_plot', marker: { size: 7.5 } };
        var data = [trace1];
        var layout = { xaxis: { title: 'Log 2 Fold Change' }, yaxis: { title: '-Log10(P Value)' }, hovermode: 'closest' };
        var parentWidth = 100;
        var volcanoPlotGd3 = Plotly.d3.select('#volcano_plot')
            .style({
                width: parentWidth + '%',
                'margin-left': (100 - parentWidth) / 2 + '%'
            });
        var volcanoPlot = volcanoPlotGd3.node();
        Plotly.newPlot(volcanoPlot, data, layout);
        return volcanoPlot;
    };

    GD.createExpressionPlot = function(response, geneId) {
        var trace1 = { x: response.group1.x, y: response.group1.y, type: 'bar', name: response.group1_name[0] };
        var trace2 = { x: response.group2.x, y: response.group2.y, type: 'bar', name: response.group2_name[0] };
        var data = [trace1, trace2];
        var layout = { barmode: 'group', xaxis: { title: 'Sample', tickangle: -40, position: -0.5 }, yaxis: { title: 'Expression' } };
        var parentWidth = 100;
        var expressionPlotGd3 = Plotly.d3.select('#' + geneId + 'Plot')
            .style({
                width: parentWidth + '%',
                'margin-left': (100 - parentWidth) / 2 + '%'
            });
        var expressionPlot = expressionPlotGd3.node();
        Plotly.newPlot(expressionPlot, data, layout);
        window.addEventListener('resize', function() {
            Plotly.Plots.resize(expressionPlot);
        });
    };

    ///// General GD functions
    GD.initializeToptable = function(dataset, tableId, tableWrapperId) {
        dataset = GD.addPlotIconToTopTable(dataset);
        $('#' + tableId).dataTable({
            "oLanguage": {
                "sStripClasses": "",
                "sSearch": "",
                "sSearchPlaceholder": "Enter Keywords Here",
                "sInfo": "_START_ -_END_ of _TOTAL_",
                "sLengthMenu": '<span>Rows per page:</span><select class="browser-default">' +
                    '<option value="10">10</option>' +
                    '<option value="20">20</option>' +
                    '<option value="30">30</option>' +
                    '<option value="40">40</option>' +
                    '<option value="50">50</option>' +
                    '<option value="-1">All</option>' +
                    '</select></div>'
            },
            data: dataset,
            order: [
                [5, "asc"]
            ],
            bAutoWidth: false
        });

        GD.makePlotIconClickable(tableWrapperId);

        $('#' + tableWrapperId).on('click', '.search-toggle', function() {
            if ($('.hiddensearch').css('display') == 'none') {
                $('.hiddensearch').slideDown();
            } else {
                $('.hiddensearch').slideUp();
            }
        });

        $('#' + tableWrapperId).on('click', '.download-top-table', function() {
            $('#modal_header_text').text('Creating Download Link');
            $('#modal_text').text('This should take a few seconds. Please leave this page open');
            $('#loading_modal').modal({ dismissible: false });
            $('#loading_modal').modal('open');
            $.fileDownload($(this).attr('href'), {
                successCallback: function() {
                    $('#loading_modal').modal('close');
                },
                failCallback: function() {
                    $('#loading_modal').modal('close');
                }
            });
            return false; //this is critical to stop the click event which will trigger a normal file download!
        });
    };

    GD.addPlotIconToTopTable = function(dataset) {
        $.each(dataset, function(key, row) {
            row.push('<i class="material-icons child-row-chart light-blue-text text-darken-3">insert_chart</i>');
        });
        return (dataset);
    };

    GD.makePlotIconClickable = function(tableWrapperId) {
        $('#' + tableWrapperId).on('click', '.child-row-chart', function() {
            var currentRow = $(this).closest('tr');
            var geneId = currentRow.children('td:first').text();
            if ($('#' + geneId + 'ChildRow').length) {
                $('#' + geneId + 'ChildRow').remove();
            } else {
                if (tableWrapperId === 'dgea-top-table-wrapper') {
                    GD.geneExpressionAjax(currentRow, geneId);
                } else if (tableWrapperId === 'gsea-top-table-wrapper') {
                    GD.interactionNetworkAjax(currentRow, geneId);
                }
            }
        });
    };

    GD.initialiatizePcaScatterPlot = function(pcnames) {
        $.each(pcnames, function(key, value) {
            $('#PC2doption1').append($("<option></option>")
                .attr("value", value).text(value));
            $('#PC2doption2').append($("<option></option>")
                .attr("value", value).text(value));
            $('#PC3doption1').append($("<option></option>")
                .attr("value", value).text(value));
            $('#PC3doption2').append($("<option></option>")
                .attr("value", value).text(value));
            $('#PC3doption3').append($("<option></option>")
                .attr("value", value).text(value));
        });
        GD.loadPcRedrawValidation();
    };

    //
    GD.addFactorToggle = function() {
        $("input:radio[name=factor]").click(function() {
            var target = '#' + $(this).attr('id') + '_select';
            if ('#' + $('.select_factors:visible').attr('id') !== target) {
                $('.select_factors').hide();
                $('.select_factors select').attr("disabled", "disabled");
                $(target).show();
                $(target + ' select').removeAttr("disabled");
            }
            $('#groupa_params').attr('data-tooltip', 'This is Group A');
            $('#groupa_params').tooltip({ delay: 50 });
            $('#groupb_params').attr('data-tooltip', 'This is Group B');
            $('#groupb_params').tooltip({ delay: 50 });
            GD.ensureOnlyOneSelectOption();
        });
    };

    GD.addAdvParamLogic = function() {
        GD.show_hide_div('#DGEA_input', '#DGEAparams');
        GD.show_hide_div('#GSEA_input', '#GSEAparams');
        GD.show_hide_div('#dgea_toptable', '#dgea_toptable_params');
        GD.show_hide_div('#dgea_heatmap', '#dgea_heatmap_params');
        GD.show_hide_div('#gsea_heatmap', '#gsea_heatmap_params');
        $("input:radio[name=gsea_type]").click(function() {
            if ($("input:radio[name=gsea_type]:checked").val() == 'ExpVsCtrl') {
                $('#gage_select_control').show();
            } else {
                $('#gage_select_control').hide();
            }
        });
    };

    GD.show_hide_div = function(checkbox, div) {
        $(checkbox).change(function() {
            if ($(this).prop("checked")) {
                $(div).show();
            } else {
                $(div).hide();
            }
        });
    };

    GD.addGeoDbInfo = function(geoAccession) {
        var accession = geoAccession.toUpperCase();

        var jsonFile = GD.protocol() + window.location.host + "/GeoDiver/DBs/" + accession + ".json";
        $.getJSON(jsonFile, function(json) {
            $('#dataset_accession').text(' ' + json.Accession);
            $('#dataset_title').text(json.Title);
            $('#dataset_summary').text(json.Description);
            $('#dataset_organism').text(json.Sample_Organism);
            $('#dataset_summary').text(json.Description);
            $('#dataset_citation').text(json.Reference);
        });
    };

    GD.addUserDropDown = function() {
        $('.dropdown-button').dropdown({
            inDuration: 300,
            outDuration: 225,
            hover: true,
            belowOrigin: true,
            alignment: 'right'
        });
    };

    GD.download_all_results = function() {
        $('#results_section').on('click', '#download-all-results', function(event) {
            event.preventDefault();
            $('#modal_header_text').text('Creating Download Link');
            $('#modal_text').text('This should take a few seconds. Please leave this page open');
            $('#loading_modal').modal({ dismissible: false });
            $('#loading_modal').modal('open');
            $.fileDownload($(this).data('download'), {
                successCallback: function() {
                    $('#loading_modal').modal('close');
                },
                failCallback: function() {
                    $('#loading_modal').modal('close');
                }
            });
            $('#loading_modal').modal('close');
            return false; //this is critical to stop the click event which will trigger a normal file download!
        });
    };

    GD.delete_result = function() {
        $('#results_section').on('click', '#delete_results', function() {
            $('#delete_modal').modal('open');
            var resultId = $(this).closest('.card').data('result');
            var geoDb = $(this).closest('.card').data('geodb');
            $('#delete_modal').attr('data-result', resultId);
            $('#delete_modal').attr('data-geodb', geoDb);
        });

        $('.delete-results').click(function() {
            $('#modal_header_text').text('Deleting Result');
            $('#modal_text').text('This should take a few seconds. Please leave this page open');
            $('#loading_modal').modal({ dismissible: false });
            $('#loading_modal').modal('open');
            var resultId = $('#delete_modal').data('result');
            var geoDb = $('#delete_modal').data('geodb');
            $.ajax({
                type: 'POST',
                url: '/delete_result',
                data: { result_id: resultId, geo_db: geoDb },
                success: function() {
                    location.reload();
                },
                error: function(e, status) {
                    GD.ajaxError(e, status);
                }
            });
        });
    };

    GD.show_GeoDB_modal = function() {
        $('#results_section').on('click', '.open_db_info_modal', function() {
            var accession = $(this).data('accession');
            GD.addGeoDbInfo(accession);
            $('#dbInfo').modal('open');
        });
    };

    GD.share_result = function() {
        $('#results_section').on('click', '#share_btn', function() {
            var share_link = $(this).closest('.card').data('share-link');
            $('#share_the_link_btn').show();
            $('#share_btn').hide();
            $('#share_link_input').val(share_link);
            $('#share_link_input').prop("readonly", true);
            $('#share_modal').modal('open');
            $('#share_modal').attr('data-share-link', share_link);
            $('#share_link_input').select();
            $.ajax({
                type: 'POST',
                url: share_link,
                error: function(e, status) {
                    GD.ajaxError(e, status);
                }
            });
        });
        $('#results_section').on('click', '#share_the_link_btn', function() {
            var share_link = $(this).closest('.card').data('share-link');
            $('#share_link_input1').val(share_link);
            $('#share_link_input1').prop("readonly", true);
            $('#share_the_link_modal').modal('open');
            $('#share_the_link_modal').attr('data-share-link', share_link);
            $('#share_link_input1').select();
        });

        $(".share_link_input").focus(function() {
            $(this).select();
            // Work around Chrome's little problem
            $(this).mouseup(function() {
                // Prevent further mouseup intervention
                $(this).unbind("mouseup");
                return false;
            });
        });
    };

    GD.remove_share = function() {
        $('.remove_link').click(function() {
            var share_link = $(this).closest('.modal').data('share-link');
            var remove_link = share_link.replace(/\/sh\//, '/rm/');
            $('#share_the_link_btn').hide();
            $('#share_btn').show();
            $('#share_modal').modal('close');
            $('#share_the_link_modal').modal('close');
            $.ajax({
                type: 'POST',
                url: remove_link,
                error: function(e, status) {
                    GD.ajaxError(e, status);
                }
            });
        });
    };

    GD.ensureOnlyOneSelectOption = function() {
        $('.select_factors:visible select[name="groupa[]"], .select_factors:visible select[name="groupb[]"]').on('change', function() {
            // RESET both arrays
            $groupAChildren = $('.select_factors:visible select[name="groupa[]"]').siblings('ul').children('li').not(':first-child');
            $groupAChildren.prop("disabled", false);
            $groupAChildren.removeClass('disabled');
            $groupAChildren.find('input:checkbox').prop('disabled', false);
            $('.select_factors:visible select[name="groupa[]"]').children().not(':first-child').prop('disabled', false);

            $groupBChildren = $('.select_factors:visible select[name="groupb[]"]').siblings("ul").children("li").not(":first-child");
            $groupBChildren.prop("disabled", false);
            $groupBChildren.removeClass('disabled');
            $groupBChildren.find('input:checkbox').prop('disabled', false);
            $('.select_factors:visible select[name="groupb[]"]').children().not(':first-child').prop('disabled', false);

            var aValues = $('.select_factors:visible select[name="groupa[]"]').val();
            var bValues = $('.select_factors:visible select[name="groupb[]"]').val();
            var selector, valueIndex;

            $.each(aValues, function(i) {
                selector = '.select_factors:visible select[name="groupb[]"] option[value="' + aValues[i] + '"]';
                $(selector).prop('disabled', true);
                valueIndex = $(selector).index() + 1;
                $('.select_factors:visible select[name="groupb[]"]').siblings('ul').children('li:nth-child(' + valueIndex + ')').addClass('disabled');
                $('.select_factors:visible select[name="groupb[]"]').siblings('ul').children('li:nth-child(' + valueIndex + ')').find('input:checkbox').prop('disabled', true);
            });
            $.each(bValues, function(i) {
                selector = '.select_factors:visible select[name="groupa[]"] option[value="' + bValues[i] + '"]';
                $(selector).prop('disabled', true);
                valueIndex = $(selector).index() + 1;
                $('.select_factors:visible select[name="groupa[]"]').siblings('ul').children('li:nth-child(' + valueIndex + ')').addClass('disabled');
                $('.select_factors:visible select[name="groupa[]"]').siblings('ul').children('li:nth-child(' + valueIndex + ')').find('input:checkbox').prop('disabled', true);
            });
        });
    };

    GD.addGraphTooltips = function() {
        $('#dgea-top-table .child-row-chart').tooltip({ tooltip: 'Show a graph for the inidividual expression levels for this Gene', position: 'left' });
        $('#gsea-top-table .child-row-chart').tooltip({ tooltip: 'Show a colour coded interaction network for this pathway', position: 'left' });
    };

    GD.setupGoogleAuthentication = function() {
        gapi.auth.authorize({
            immediate: true,
            response_type: 'code',
            cookie_policy: 'single_host_origin',
            client_id: GD.CLIENT_ID,
            scope: 'email'
        });
        $('.login_button').on('click', function(e) {
            e.preventDefault();
            /** global: gapi */
            gapi.auth.authorize({
                immediate: false,
                response_type: 'code',
                cookie_policy: 'single_host_origin',
                client_id: GD.CLIENT_ID,
                scope: 'email'
            }, function(response) {
                if (response && !response.error) {
                    // google authentication succeed, now post data to server.
                    jQuery.ajax({
                        type: 'POST',
                        url: "/auth/google_oauth2/callback",
                        data: response,
                        success: function() {
                            // TODO - just update the DOM instead of a redirect
                            $(location).attr("href", GD.protocol() + window.location.host + "/analyse");
                        }
                    });
                } else {
                    console.log('ERROR Response google authentication failed');
                    // TODO: ERROR Response google authentication failed
                }
            });
        });
    };

    GD.protocol = function() {
        if (GD.USING_SLL === "true") {
            return "https://";
        } else {
            return "http://";
        }
    };
}());

(function($) {
    $.fn.exists = function() { return this.length > 0; };

    // Fn to allow an event to fire after all images are loaded
    $.fn.imagesLoaded = function() {
        var $imgs = this.find('img[src!=""]');
        // if there's no images, just return an already resolved promise
        if (!$imgs.length) { return $.Deferred().resolve().promise(); }

        // for each image, add a deferred object to the array which resolves when the image is loaded (or if loading fails)
        var dfds = [];
        $imgs.each(function() {
            var dfd = $.Deferred();
            dfds.push(dfd);
            /** global: Image */
            var img = new Image();
            img.onload = function() { dfd.resolve(); };
            img.onerror = function() { dfd.resolve(); };
            img.src = this.src;
        });
        // return a master promise object which will resolve when all the deferred objects have resolved
        // i.e. - when all the images are loaded
        return $.when.apply($, dfds);
    };

    $(function() {
        $('.button-collapse').sideNav();
        $('select').material_select();
        $('#login_modal').modal();
        $('.modal').modal();
        if ($('#load_geo_db').length) {
            GD.setUpValidatorDefaults();
            GD.loadGeoDbValidation();
        }
        if ($('#exemplar_result').length) { GD.exemplar_results(); }
        GD.addUserDropDown();
    });

    $(function() {
        return $.ajax({
            url: 'https://apis.google.com/js/client:plus.js?onload=gpAsyncInit',
            dataType: 'script',
            cache: true
        });
    });

    window.gpAsyncInit = function() {
        GD.setupGoogleAuthentication();
    };
})(jQuery);