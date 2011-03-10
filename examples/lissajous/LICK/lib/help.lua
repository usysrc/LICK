-- parse the classes to readable html

module(..., package.seeall)

filename = "LICK/lib/object.lua"
help_filename = "LICK/lib/docs/"

-- some styles
local style = "<style type=\"text/css\">p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 13.0px Helvetica}p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 18.0px Helvetica; min-height: 22.0px}p.p3 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica}p.p4 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; min-height: 14.0px}p.p5 {margin: 0.0px 0.0px 0.0px 0.0px; font: 9.0px Monaco}p.p6 {margin: 0.0px 0.0px 0.0px 0.0px; font: 9.0px Monaco; min-height: 12.0px}p.p7 {margin: 0.0px 0.0px 0.0px 0.0px; font: 9.0px Monaco; color: #9d1c12}p.p8 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Monaco; min-height: 16.0px}span.s1 {font: 18.0px Helvetica}span.s2 {color: #0026b4}span.Apple-tab-span {white-space:pre}</style>"

local header1 = "<HTML><HEAD><TITLE>"
local header2 = "</TITLE>"..style.."</HEAD><BODY>"
local footer = "</BODY></HTML>"
local _newclasstitle = "<h3>"
local newclasstitle_ = "</h3>"
local tab = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"


-- generates the html file
function generate()
	class_file = love.filesystem.newFile( filename )
	class_file:open('r')
	local output = ""
	output = header1.."test"..header2
	local found_methods = 0
	local found_classes = 0
	local classes = {}
	for line in class_file:lines() do
		local b,e = string.find(line,"@")
		local b1,e1 = string.find(line,"Class")
		if b and e then
			if found_classes > 0 then
				output = output..footer
				writeClassFile(name, output)
				local output = ""
			
			end
			dp,ep = string.find(line, ":")
			name = line:sub(e+1, dp-1 or 0)
			print(name)
			table.insert(classes,name)
			output = header1..name..header2

			output = output .._newclasstitle .. name..tab..tab..line:sub(dp+1) ..newclasstitle_
						found_methods = 0
			found_classes = found_classes + 1
		elseif b1 and e1 and not string.find(line,"require")  then
			output = output .."<h4>"..tab..line:sub(e1+2).."</h4>"..tab..tab.."<i> Constructor</i>"

		end
		local b,e = string.find(line,"#")
		if method then
			local dp,ep = string.find(line, ":")
			ep = ep or 1
			if found == 0 then
				output = output .."<h3>Methods</h3>"
				found_methods = found_methods + 1
			end
			output = output.."<h4>".. tab ..line:sub(ep+1).."</h4>"..tab..tab..method
			method = nil
		end
		if b and e then
			method = line:sub(e+1).."<br>"

			--output = output..line:sub(e+1).."<br>"
		end
	end
	output = output..footer
	writeClassFile(name, output)

	-- generate index.html
	index = header1.."live_libs_doc"..header2
	index = index.."<h3>live_libs documentation</h3>"
	index = index .. "<a href=\"guidelines.html\">Guidelines for new classes and commenting</a>"
	index = index.. "<h4>Classes:</h4>"
	for i,v in ipairs(classes) do
		index = index.."<a href=\"classes/"..v..".html".."\">"..v.."</a> <br>"
	end
	index = index..footer
	writeFile("index", index)

	
end

function writeClassFile(name, output)
	dir = love.filesystem.getWorkingDirectory( )
	--print("touch "..dir.."/"..help_filename)
	local path = dir.."/live_testproject/"..help_filename.."classes/"..name..".html"
	os.execute("touch "..path)
	
	local helpfile = io.open(path, "w" )
	helpfile:write(output)
	helpfile:close()

end

function writeFile(name, output)
	dir = love.filesystem.getWorkingDirectory( )
	--print("touch "..dir.."/"..help_filename)
	local path = dir.."/live_testproject/"..help_filename..name..".html"
	os.execute("touch "..path)
	
	local helpfile = io.open(path, "w" )
	helpfile:write(output)
	helpfile:close()

end


