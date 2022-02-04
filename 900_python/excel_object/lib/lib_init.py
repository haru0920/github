# 図形の付加情報
dict_fix_name = {
    'Rectangle':{'desc':'処理', 'kubun':0}
    , 'Diamond':{'desc':'判定', 'kubun':1}
    , 'Flowchart: Decision':{'desc':'判定終端', 'kubun':-1}
    , 'Trapezoid':{'desc':'繰り返し', 'kubun':2}
    , 'Flowchart: Manual Operation':{'desc':'繰り返し終端', 'kubun':-2}
    , 'Straight Connector':{'desc':'直線', 'kubun':99}
    , 'Elbow Connector':{'desc':'カギ線', 'kubun':99}
}

td_operator_list = [
    'td_load'
    , 'td'
]

# ネスト時の文字列
nest_str = '    '

# テンプレートExcelファイル名
filename_tmp = 'template_setting.xlsx'