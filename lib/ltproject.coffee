path = require 'path'
fs = require 'fs'
{Directory} = require 'atom'

module.exports =

class LTProject
  constructor: ->
    console.log 'Create projct settings'

    @TEXroot = null

    # finding .lt-projet file in project path
    buffer_path = path.dirname(atom.workspace.getActiveTextEditor().getPath())
    current_path = buffer_path
    project_file = null

    # search .lt-projet file in current editor's ancestors' path
    while project_file is null

      # if the root dir, means do not have a .lt-project settings
      if current_path == '/'
        console.log "Can not file .lt-project in all paths of current file"
        break

      current_dir = new Directory(current_path)

      # check if '.lt-project' exist
      try
        fs.accessSync path.normalize("#{current_path}/.lt-project"),fs.F_OK
        project_file = path.normalize("#{current_path}/.lt-project")
        console.log "find project config file, its path is :#{project_file}"
      catch error
        current_path = path.resolve(current_path, "..")


    # if find project
    if project_file?

      # record project's absolute dir
      project_dir = path.dirname(project_file)

      # check if project_file is is project's paths
      # if so, set atom project
      if project_file not in atom.project.getPaths()
        atom.project.addPath(project_dir)
        if buffer_path != project_dir
          atom.project.removePath(buffer_path)

      project_config = JSON.parse(fs.readFileSync(project_file, encoding='utf-8'))

      # configring "TEXroot"
      if "TEXroot" in key for key of project_config
        tex_root = project_config["TEXroot"]
        if not path.isAbsolute(tex_root)
          tex_root = path.normalize(project_dir + '/' + tex_root)
        @TEXroot = tex_root
