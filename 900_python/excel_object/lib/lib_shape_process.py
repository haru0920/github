import shutil
import lib.lib_init as var

# 図形の処理
def process_shape(current_shape, nest, dict_shape, template_dir, base_dir, fp, df, wb_tmp, wb):
    # 処理：四角
    if dict_shape[current_shape]['add_info']['kubun'] == 0:
        process_shape_process(current_shape, nest, dict_shape, template_dir, base_dir, fp, df, wb_tmp, wb)
        
    # 判定：ひし形
    elif dict_shape[current_shape]['add_info']['kubun'] == 1:
        process_shape_judgement(current_shape, nest, 0, dict_shape, fp)
    
    # 繰り返し：台形
    elif dict_shape[current_shape]['add_info']['kubun'] == 2:
        process_shape_loop(current_shape, nest, dict_shape, df, template_dir, base_dir, fp)

# 図形の処理：処理(四角)
def process_shape_process(current_shape, nest, dict_shape, template_dir, base_dir, fp, df, wb_tmp, wb):

    #　タスク名を取得
    task_name = dict_shape[current_shape]['text'][0]
    
    # 処理タイプを取得
    type_name = dict_shape[current_shape]['text'][1]

    # 管理ファイルから情報を取得
    management_info = df[df['type'] == type_name]

    # テンプレートファイルをコピー(exe)
    # print(management_info['exe_filename'].iloc[0].split('.'))
    extension = management_info['exe_filename'].iloc[0].split('.')[1]
    src = template_dir + management_info['exe_filename'].iloc[0]
    dest = '{}/{}/{}_{}.{}'.format(base_dir, management_info['exe_dir'].iloc[0], task_name, type_name, extension)
    shutil.copy(src, dest)

    # テンプレートファイルをコピー(dig)
    src = template_dir + management_info['dig_filename'].iloc[0]
    dig_filename = '{}_{}.dig'.format(task_name, type_name)
    dest = '{}/digs/{}'.format(base_dir, dig_filename)
    shutil.copy(src, dest)
    
    # テンプレートファイルの中の特定オペレーションの後にファイル名を指定(dig)
    fp_dig = open(dest)
    data = fp_dig.read()
    fp_dig.close()
    for operator in var.td_operator_list:
        if operator + '>:' in data:
            data = data.replace(operator + '>:', operator + '>: ../{}/{}_{}.{}'.format(management_info['exe_dir'].iloc[0], task_name, type_name, extension))
            break
    fp_dig = open(dest, mode='w')
    fp_dig.write(data)
    fp_dig.close()

    # テンプレートシートをコピー(excel)
    sheet_name = management_info['exe_setting_sheet'].iloc[0]
    if type(sheet_name) is str:
        wb_tmp.sheets[sheet_name].copy(after=wb.sheets[-1], name='{}_{}'.format(task_name, type_name))

    # メインとなるdigファイルに出力
    if len(dict_shape[current_shape]['text']) > 2:
        fp.write('{}# {}\n'.format(var.nest_str * nest, dict_shape[current_shape]['text'][2]))
    fp.write('{}+{}:\n'.format(var.nest_str * nest, task_name))
    fp.write('{}  call>: digs/{}\n\n'.format(var.nest_str * nest, dig_filename))

# 図形の処理：判定(ひし形)
# flag = 0：if処理 flag = 1：else処理
def process_shape_judgement(current_shape, nest, flag, dict_shape, fp):

    if flag == 0:
        #　タスク名を取得
        task_name = dict_shape[current_shape]['text'][0]

        # メインとなるdigファイルに出力
        if len(dict_shape[current_shape]['text']) > 1:
            fp.write('{}# {}\n'.format(var.nest_str * nest, dict_shape[current_shape]['text'][1]))

        fp.write('{}+{}:\n'.format(var.nest_str * nest, task_name))
        fp.write('{}  if>: \n'.format(var.nest_str * nest))
        fp.write('{}  _do:\n\n'.format(var.nest_str * nest))
    
    else:
        # メインとなるdigファイルに出力
        fp.write('{}  _else_do:\n\n'.format(var.nest_str * nest))

# 図形の処理：繰り返し(台形)
def process_shape_loop(current_shape, nest, dict_shape, df, template_dir, base_dir, fp):
    
    #　タスク名を取得
    task_name = dict_shape[current_shape]['text'][0]
    
    # 処理タイプを取得
    type_name = dict_shape[current_shape]['text'][1]

    # 管理ファイルから情報を取得
    management_info = df[df['type'] == type_name]

    # テンプレートファイルをコピー(exe)
    if len(management_info['exe_filename'].iloc[0]) != 0:
        extension = management_info['exe_filename'].iloc[0].split('.')[1]
        src = template_dir + management_info['exe_filename'].iloc[0]
        dest = '{}/{}/{}_{}.{}'.format(base_dir, management_info['exe_dir'].iloc[0], task_name, type_name, extension)
        shutil.copy(src, dest)
    
    # メインとなるdigファイルに出力
    if len(dict_shape[current_shape]['text']) > 2:
        fp.write('{}# {}\n'.format(var.nest_str * nest, dict_shape[current_shape]['text'][2]))

    fp.write('{}+{}:\n'.format(var.nest_str * nest, task_name))
    management_info = df[df['type'] == type_name]
    with open(template_dir + management_info['dig_filename'].iloc[0], 'r') as f:
        for line in f:
            if '{{file_name}}' in line:
                output = line.replace('{{file_name}}', '{}/{}_{}.{}'.format(management_info['exe_dir'].iloc[0], task_name, type_name, extension))
            else:
                output = line
            fp.write('{}{}'.format(var.nest_str * nest, output))
    fp.write('\n\n')
    
# 図形の探索
def search_shape(list_fin, list_stack_process, list_stack_termination, nest, dict_shape, fp, template_dir, base_dir, df, wb_tmp, wb):
    #print('==========')
    #print('list_fin：' + str(list_fin))
    #print('list_stack_process：' + str(list_stack_process))
    #print('list_stack_termination：' + str(list_stack_termination))
    #print('nest：' + str(nest))
    
    current_shape = -1
        
    # スタックされている処理を取得
    if len(list_stack_process) != 0:
        current_shape = list_stack_process.pop()
        process_shape(current_shape, nest, dict_shape, template_dir, base_dir, fp, df, wb_tmp, wb)
        
        # 判定か繰り返しを処理した場合、nestをインクリメント
        if dict_shape[current_shape]['add_info']['kubun'] in [1, 2]:
            nest += 1
        list_fin.append(current_shape)
            
    # 終端図形の番号を取得し、nestをデクリメント
    elif len(list_stack_termination) != 0:
        while len(list_stack_termination) != 0:
            current_shape = list_stack_termination.pop()
            if current_shape not in list_fin:
                list_fin.append(current_shape)
                nest -= 1
                while 1:
                    try:
                        list_stack_termination.remove(current_shape)
                    except ValueError as e:
                        break
                break

    # 全て処理し終えていたらreturn
    if len(list_fin) == dict_shape['cnt']:
        return list_fin, list_stack_process, list_stack_termination, nest
    
    # out_line_noから次の図形を探索
    for out_line in dict_shape[current_shape]['out_line_no']:
        i = 0
                
        for i in range (0, dict_shape['cnt']):
            if out_line in dict_shape[i]['in_line_no']:
                # 見つかった図形が終端の場合は終端リストに格納
                if dict_shape[i]['add_info']['kubun'] < 0:
                    list_stack_termination.append(i)
                
                # 見つかった図形が終端ではない場合再帰処理
                else:
                    # 判定の2つめのout_line_noが終端以外に紐付いている場合、else句
                    if dict_shape[current_shape]['add_info']['kubun'] == 1 and dict_shape[current_shape]['out_line_no'][1] == out_line:
                        process_shape_judgement(current_shape, nest - 1, 1, dict_shape, fp)
                    list_stack_process.append(i)
                    list_fin, list_stack_process, list_stack_termination, nest = search_shape(list_fin, list_stack_process, list_stack_termination, nest, dict_shape, fp, template_dir, base_dir, df, wb_tmp, wb)
                break

    return list_fin, list_stack_process, list_stack_termination, nest

def main_shape_process(dict_shape, fp, template_dir, base_dir, df, wb_tmp, wb):
    list_fin = []
    list_stack_process = []
    list_stack_termination = []
    nest = 0
    while len(list_fin) != dict_shape['cnt']:
        
        # はじめの図形の処理
        if len(list_fin) == 0 and len(list_stack_process) == 0 and len(list_stack_termination) == 0:
            i = 0
            for i in range (0, dict_shape['cnt']):
                if len(dict_shape[i]['in_line_no']) == 0:
                    list_stack_process.append(i)
                    break
            continue
        
        # 図形の探索
        list_fin, list_stack_process, list_stack_termination, nest = search_shape(list_fin, list_stack_process, list_stack_termination, nest, dict_shape, fp, template_dir, base_dir, df, wb_tmp, wb)