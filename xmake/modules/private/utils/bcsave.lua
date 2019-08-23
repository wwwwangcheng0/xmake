--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        bcsave.lua
--

-- imports
import("core.base.option")
import("lib.luajit.bcsave")

-- the options
local options =
{
    {'s', "strip",      "k",  false,            "Strip the debug info."                      }
,   {'o', "outputdir",  "kv", nil,              "Set the output directory of bitcode files." }
,   {nil, "sourcedir",  "v",  os.programdir(),  "Set the directory of lua source files."     }
}

-- save lua files to bitcode files in the given directory
function save(sourcedir, outputdir, opt)

    -- check
    assert(outputdir, "no output directory!")

    -- init source directory and options
    opt = opt or {}
    sourcedir = sourcedir or os.programdir()
    assert(os.isdir(sourcedir), "%s not found!", sourcedir)

    -- trace
    print("generating bitcode files from %s ..", sourcedir)

    -- save all lua files to bitcode files
    local oldir = os.cd(sourcedir)
    for _, luafile in ipairs(os.files(path.join(sourcedir, "**.lua"))) do

        -- get relative lua file path to decrease bitcode file size (without strip)
        luafile = path.relative(luafile, sourcedir)

        -- trace
        vprint("generating %s ..", luafile)

        -- get bitcode file path
        local bcfile = path.join(outputdir, luafile)
        
        -- generate bitcode file
        bcsave(luafile, bcfile, {strip = opt.strip})
    end
    os.cd(oldir)

    -- trace
    cprint("${bright}bitcode files have been generated in %s", outputdir)
end

-- main entry
function main(...)

    -- parse arguments
    local argv = {...}
    local opt  = option.parse(argv, options, "Save all lua files to bitcode files."
                                           , ""
                                           , "Usage: xmake l private.utils.bcsave [options]")

    -- check outputdir
    if not opt.outputdir then
        opt.help() 
        raise("please set output directory!")
    end

    -- save bitcode files
    save(opt.sourcedir, opt.outputdir, opt)
end
