-- 固定使用 bash 调用所有命令：避免 fish/nu 这类配置较重的 shell
-- 在每次启动 / 每次 fzf reload / preview 时都被冷启动，造成明显延迟。
local SHELL = "bash"

local preview_cmd =
	[===[line={2} && begin=$( if [[ $line -lt 7 ]]; then echo $((line-1)); else echo 6; fi ) && bat --highlight-line={2} --color=always --line-range $((line-begin)):$((line+10)) {1}]===]

local rg_prefix = "rg --column --line-number --no-heading --color=always --smart-case "
local rga_prefix =
	"rga --files-with-matches --color ansi --smart-case --max-count=1 --no-messages --hidden --follow --no-ignore --glob '!.git' --glob !'.venv' --glob '!node_modules' --glob '!.history' --glob '!.Rproj.user' --glob '!.ipynb_checkpoints' "

local fzf_args = [[fzf --preview='bat --color=always {1}']]
local rg_args = [[fzf --ansi --disabled --bind "start:reload:]]
	.. rg_prefix
	.. [[{q}" --bind "change:reload:sleep 0.1; ]]
	.. rg_prefix
	.. [[{q} || true" --delimiter : --preview ']]
	.. preview_cmd
	.. [[' --preview-window 'up,60%' --nth '3..']]
local rga_args = [[fzf --ansi --disabled --layout=reverse --sort --header-first --header '---- Search inside files ----' --bind "start:reload:]]
	.. rga_prefix
	.. [[{q}" --bind "change:reload:sleep 0.1; ]]
	.. rga_prefix
	.. [[{q} || true" --delimiter : --preview 'rga --smart-case --pretty --context 5 {q} {}' --preview-window 'up,60%' --nth '3..']]
local fg_args = [[rg --color=always --line-number --no-heading --smart-case '' | fzf --ansi --preview=']]
	.. preview_cmd
	.. [[' --delimiter=':' --preview-window='up:60%' --nth='3..']]

local function split_and_get_first(input, sep)
	if sep == nil then
		sep = "%s"
	end
	local start, _ = string.find(input, sep)
	if start then
		return string.sub(input, 1, start - 1)
	end
	return input
end

local state = ya.sync(function() return cx.active.current.cwd end)

local function fail(s, ...) ya.notify { title = "fg", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_, job)
	local permit = ui.hide()
	local cwd = tostring(state())
	local cmd_args = ""

	if job.args[1] == "fzf" then
		cmd_args = fzf_args
	elseif job.args[1] == "rg" then
		cmd_args = rg_args
	elseif job.args[1] == "rga" then
		cmd_args = rga_args
	else
		cmd_args = fg_args
	end

	-- 把 SHELL 改成 bash 一并传给子进程，使 fzf 内部
	-- 触发的 reload / preview 子命令也走 bash，而不是
	-- 用户配置厚重的登录 shell（如 fish），消除每次输入
	-- 都冷启动一次 shell 带来的卡顿。
	local child, err = Command(SHELL)
		:arg({ "-c", cmd_args })
		:cwd(cwd)
		:env("SHELL", SHELL)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Spawn command failed with error code %s.", err)
	end

	local output, err = child:wait_with_output()
	permit:drop()

	if not output then
		return fail("Cannot read `fzf` output, error code %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")

	local file_url = split_and_get_first(target, ":")

	if file_url ~= "" then
		ya.emit(file_url:match("[/\\]$") and "cd" or "reveal", { file_url })
	end
end

return { entry = entry }
