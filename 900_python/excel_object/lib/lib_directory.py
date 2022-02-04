import os
import lib.lib_init as var

# workflowディレクトリの生成
def init_dir(base_dir, output_dir, project_name):
  mkdir_list = [
      base_dir
      , base_dir + '/configs'
      , base_dir + '/digs'
      , base_dir + '/queries'
      , base_dir + '/contents'
      , base_dir + '/other'
  ]
  for mkdir in mkdir_list:
      os.mkdir(mkdir)