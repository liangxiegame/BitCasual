baseDirForScriptSelf=$(cd "$(dirname "$0")"; pwd)
cd ${baseDirForScriptSelf}/
cd ../Client/

mv src src_lua


cocos luacompile -s src_lua -d src -e -k liangxiegame -b liangxiegame  --disable-compile
