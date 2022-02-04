import lib.lib_init as var

# 図形情報の辞書化
def get_shape_dict(sheet):
  dict_org = {}
  i = 0
  for s in sheet.shapes:
      # 凡例は除く
      if s.left >= 0 and s.left <= 400:
          continue
      tmp_dict = {}
      # 図形の名称
      tmp_dict['name'] = s.name
      # 図形のY軸上端
      tmp_dict['top'] = round(s.top)
      # 図形のX軸左端
      tmp_dict['left'] = round(s.left)
      # 図形の幅
      tmp_dict['width'] = round(s.width)
      # 図形の高さ
      tmp_dict['height'] = round(s.height)
      # 図形内のテキスト
      tmp_dict['text'] = str(s.text).split('\n')
      dict_org[i] = tmp_dict
      i +=1
  return dict_org

# 図形付加情報,X軸下端,Y軸右端を追加
def add_shape_info(dict_org):
    i = 0
    for i in range (0, len(dict_org)):
        # 図形形状
        dict_org[i]['add_info'] = var.dict_fix_name[(' ').join(dict_org[i]['name'].split(' ')[:-1])]
        # X軸下端
        dict_org[i]['bottom'] = dict_org[i]['top'] + dict_org[i]['height']
        # Y軸右端
        dict_org[i]['right'] = dict_org[i]['left'] + dict_org[i]['width']
    return dict_org

# 図形と線を分離
def split_shape_line_dict(dict_org):
    dict_shape = {}
    dict_line = {}
    i = 0
    shape_cnt = 0
    line_cnt = 0
    for i in range (0, len(dict_org)):
        if dict_org[i]['add_info']['kubun'] != 99:
            dict_shape[shape_cnt] = dict_org[i]
            shape_cnt += 1
        else:
            dict_line[line_cnt] = dict_org[i]
            line_cnt += 1
    dict_shape['cnt'] = shape_cnt
    dict_line['cnt'] = line_cnt
    return dict_shape, dict_line

# 図形のin_point/out_pointを付与
def add_shape_info_point(dict_shape):
    i = 0
    j = 0
    for i in range (0, dict_shape['cnt']):
        dict_shape[i]['in_point'] = (round(dict_shape[i]['left'] + (dict_shape[i]['width'] / 2)), dict_shape[i]['top'])
        dict_shape[i]['out_point'] = [
            (round(dict_shape[i]['left'] + (dict_shape[i]['width'] / 2)), dict_shape[i]['bottom'])
            , (dict_shape[i]['right'], round(dict_shape[i]['top'] + (dict_shape[i]['height'] / 2)))
        ]
    return dict_shape

# 図形のin_line_no/out_line_noを付与
def add_shape_info_lineno(dict_shape, dict_line):
    i = 0
    j = 0

    for i in range (0, dict_shape['cnt']):
        in_point = dict_shape[i]['in_point']
        out_point = dict_shape[i]['out_point']
        tmp_in_line_no = []
        tmp_out_line_no = []
        for j in range(0, dict_line['cnt']):
            # in_line_no
            if (dict_line[j]['left'] <= in_point[0]) and (dict_line[j]['right'] >= in_point[0]) and (dict_line[j]['bottom'] == in_point[1]):
                tmp_in_line_no.append(j)
            # out_line_no
            for tmp_out_point in out_point:
                if (dict_line[j]['left'] <= tmp_out_point[0]) and (dict_line[j]['right'] >= in_point[0]) and (dict_line[j]['top'] == tmp_out_point[1]):
                    tmp_out_line_no.append(j)
        dict_shape[i]['in_line_no'] = tmp_in_line_no
        dict_shape[i]['out_line_no'] = tmp_out_line_no
    return dict_shape