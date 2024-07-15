
ROOT=$(readlink -f $(dirname $0))

if [ -e /project/env.sh ];then
    echo '[Custom Env]'
    source /project/env.sh
fi
echo '[Extract]'
echo PWD=$(pwd)
cp $0 /project/entry.sh
cd /project/packages
echo Extracting packages...
for i in `ls *.deb`;
    do dpkg -x $i $PREFIX;
done

echo '[Test Symbol Link]'
find $PREFIX -type l | while read -r SYMLINK; do
    # TARGET=`readlink  "$SYMLINK"`
    TARGET_ABS=`readlink -f "$SYMLINK"`
    TARGET_USR2F=`echo $SYMLINK|sed "s+$LINGLONG_PKG_NAME/files/usr+$LINGLONG_PKG_NAME/files/opt/apps/$PKG_NAME/files+g"`
    TARGET_F2USR=`echo $SYMLINK|sed "s+/opt/apps/$PKG_NAME/files+/usr+g"`
    if [ "$TARGET_USR2F" == "$TARGET_ABS" ] || [ "$TARGET_F2USR" == "$TARGET_ABS" ];then
        rm -v $SYMLINK
    fi
done

echo "Copying /usr/*"
cp -raf $PREFIX/usr/* $PREFIX 2>/dev/null

echo "Copying /opt/apps/$PKG_NAME/files/usr"
cp -raf $PREFIX/opt/apps/$PKG_NAME/files/usr/* $PREFIX 2>/dev/null||cp -raf $PREFIX/opt/apps/*/files/usr/* $PREFIX 
rm -rf "$PREFIX/opt/apps/$PKG_NAME/files/usr"||rm -rf $PREFIX/opt/apps/*/files/usr

echo "Copying /opt/apps/$PKG_NAME/files/*"
cp -raf $PREFIX/opt/apps/$PKG_NAME/files/* $PREFIX 2>/dev/null||cp -raf $PREFIX/opt/apps/*/files/* $PREFIX 2>/dev/null

cp -raf $PREFIX/bin/usr/* $PREFIX 2>/dev/null

rm -rf $PREFIX/bin/usr



# echo "Copying /opt/apps/$PKG_NAME/files/usr/*" 2>/dev/null
# cp -raf $PREFIX/opt/apps/$PKG_NAME/files/usr/* $PREFIX 2>/dev/null

# echo "Copying /opt/apps/$PKG_NAME/files/opt/*" 2>/dev/null
# cp -raf $PREFIX/opt/apps/$PKG_NAME/files/opt/* $PREFIX 2>/dev/null

echo "Copying Shortcut Iocns"
mkdir -p $PREFIX/share 2>/dev/null
cp -raf $PREFIX/opt/apps/$PKG_NAME/entries/* "$PREFIX/share"

if [ -d $PREFIX/pixmaps ];then
    echo Copying /pixmaps
    mkdir -p $PREFIX/share/pixmaps 2>/dev/null
    cp -vra $PREFIX/pixmaps/* $PREFIX/share/pixmaps
fi
echo '[Patch Icon Pixmaps]'
if [ -d $PREFIX/share/pixmaps ];then
    if [ ! -d $PREFIX/share/icons ];then
        mkdir -p $PREFIX/share/icons 2>/dev/null
    fi
    cp -r $PREFIX/share/pixmaps/* $PREFIX/share/icons
else
    mkdir -p $PREFIX/share/pixmaps
    cp -r $PREFIX/share/icons/* $PREFIX/share/pixmaps
fi
rm $PREFIX/share/applications/python3.7.desktop 2>/dev/null
rm $PREFIX/share/applications/openjdk-8-policytool.desktop 2>/dev/null

echo '[Patch Application Desktop]'
for i in `ls $PREFIX/share/applications/*.desktop`;do
    if echo "$i"|grep -vq "$DESKTOP_NAME" || grep -q "/usr/local" "$i";then
        rm -v "$i"
        continue
    fi
    echo Patch $i
    for j in `grep '^Icon=' $i | sed -e 's/^Icon=//g' -e "s+$PKG_NAME/entries+$LINGLONG_PKG_NAME/files/share+g" -e 's+$PKG_NAME/+$LINGLONG_PKG_NAME/+g' `;do
        if [ -e "$j" ];then
            ln -vs $j $PREFIX/share/icons/$(basename $j)
        fi
    done
    sed -E -i -e "/^Exec/ s+$F_EXEC_RAW+$F_STARTUP+g" \
                -e "s+$PKG_NAME/entries+$LINGLONG_PKG_NAME/files/share+g" \
                -e "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g" \
                -e '/^Icon\s*=\s*\W/ s#\.(png|jpg|svg|jpeg|xpm)\s*$##gi'  \
                "$i"
    cp -a $PREFIX/share/icons/hicolor/*/apps/* $PREFIX/share/icons
    ABSICON=`cat $i|grep -oP 'Icon\s*=\s*\K/.*'`
    if [ -n "$ABSICON" ];then
        cp -v ${ABSICON}* $PREFIX/share/icons
    fi
    sed -i '/Icon/ s+\S*/+Icon=+g' "$i"
done

mkdir -p $PREFIX/bin 2>/dev/null



if [ -e /project/build.sh ];then
    echo '[Custom Build]'
    echo Exec /project/build.sh
    bash /project/build.sh
fi

if [ -e $PREFIX/bin/start.sh ];then
    mv -v $PREFIX/bin/start.sh $PREFIX/bin/_start.sh
    if echo $F_EXEC|grep -qF "start.sh";then
        echo 'Reset F_EXEC' $F_EXEC
        F_EXEC=_start.sh
    fi
fi

echo "#!/bin/bash">$PREFIX/bin/start.sh

if [ -z $NO_LINK ];then
    for i in `ls $PREFIX/usr/share`;do
        if [ ! -e "/usr/share/$i" ];then
            echo ln -sf "$PREFIX/share/$i" "/usr/share/$i" 2\>/dev/null  | tee -a $PREFIX/bin/start.sh
        fi
    done

    echo ln -sf "/opt/apps/$LINGLONG_PKG_NAME" "/opt/apps/$PKG_NAME" 2\>/dev/null  | tee -a  $PREFIX/bin/start.sh
    echo ln -sf "/opt/apps/$LINGLONG_PKG_NAME/files/share" "/opt/apps/$LINGLONG_PKG_NAME/files/usr" 2\>/dev/null | tee -a $PREFIX/bin/start.sh
    # 链接了opt，但未删除opt，暂不处理
    echo ln -sf "/opt/apps/$LINGLONG_PKG_NAME/files/share" "/opt/apps/$LINGLONG_PKG_NAME/files/opt" 2\>/dev/null | tee -a  $PREFIX/bin/start.sh
fi

if [ -z $NO_GAMES ]&&[ -d "$PREFIX/games" ];then
    echo '[PATCH GAMES PATH]'
    echo export PATH="\$PATH:$PREFIX/games" 2\>/dev/null | tee -a $PREFIX/bin/start.sh
fi


if [ -e "$PREFIX/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37" ];then
    echo '[PATCH WEBKIT]'
    cp -vaf "$ROOT/libwebkit2gtk-4.0.so.37.fixed" "$PREFIX/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37"
    chmod +x "$PREFIX/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37"
    echo ln -sf "$PREFIX/lib/x86_64-linux-gnu/webkit2gtk-4.0/" "/usr/share/webkit2gtk-4.0" 2\>/dev/null | tee -a $PREFIX/bin/start.sh
fi

JACKS="$PREFIX/lib/x86_64-linux-gnu/libjackserver.so.0.1.0" 
JACKD="$PREFIX/lib/x86_64-linux-gnu/libjack.so.0.1.0" 
if [ -e "$JACKS" ] ||  [ -e "$JACKD" ];then
    echo '[PATCH JACK]'
    cp -vaf "$ROOT/libjackserver.so.0.1.0.fixed" "$JACKS"
    cp -vaf "$ROOT/libjack.so.0.1.0.fixed" "$JACKD"
    chmod +rx "$JACKS"
    chmod +rx "$JACKD"
fi


rm -rf $PREFIX/usr $PREFIX/opt/apps
echo ln -sf "$PREFIX" "/usx" 2\>/dev/null | tee -a $PREFIX/bin/start.sh

echo "export SHELL=/bin/bash"  | tee -a $PREFIX/bin/start.sh


if [ -z $NO_TERM ];then
    echo export TERM=xterm-256color | tee -a $PREFIX/bin/start.sh
fi

if [ -z $NO_LDPATH ];then
    LD_PATH=`find $PREFIX -name "*.so*"|xargs dirname|grep -v "/lib/jvm"|sort|uniq|paste -sd :`
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/lib:/usr/lib/x86_64-linux-gnu:$LD_PATH"  | tee -a $PREFIX/bin/start.sh
fi
if [ -z "$NO_MONO" ];then
    MONO_PATH=`find $PREFIX -name "*.dll"|xargs dirname|sort|uniq|paste -sd :`
    if [ -n "$MONO_PATH" ];then
        echo "export MONO_PATH=\$MONO_PATH:$MONO_PATH"  | tee -a  $PREFIX/bin/start.sh
    fi
fi
if [ -z "$NO_GLIB" ]&&([ -e "$PREFIX/lib/girepository-1.0" ]||[ -e "$PREFIX/lib/x86_64-linux-gnu/girepository-1.0" ]);then
    echo "export GI_TYPELIB_PATH=$PREFIX/lib/girepository-1.0:$PREFIX/lib/x86_64-linux-gnu/girepository-1.0" | tee -a  $PREFIX/bin/start.sh
fi

if  [ -z "$NO_JAVA" ]&&[ -d $PREFIX/lib/jvm ]||[ -n "$JAVA_HOME" ];then
    if [ -z "$JAVA_HOME" ];then
        if [ -d $PREFIX/lib/jvm/default-java/bin/java ];then
            JAVA_HOME=$PREFIX/lib/jvm/default-java
        else
            for i in 8 11;do
                JAVA_HOME=$PREFIX/lib/jvm/java-$i-openjdk-amd64 
                if [ -d $JAVA_HOME ];then
                    break
                fi
            done
        fi
    fi
    echo JAVA_HOME=$JAVA_HOME
    JAVA_PATH=$JAVA_HOME/bin
    if [ ! -e $JAVA_PATH/java ];then
        echo ERROR: BAD JAVA_PATH=$JAVA_PATH
    fi
    echo "export PATH=\$PATH:$JAVA_PATH" | tee -a  $PREFIX/bin/start.sh
    echo "export JAVA_HOME=$JAVA_HOME"  | tee -a  $PREFIX/bin/start.sh
fi 
if  [ -z "$NO_PREL" ]&&[ -e $PREFIX/bin/perl5.28-x86_64-linux-gnu ]||[ -n "$PERL5LIB" ];then
    echo "export PERL5LIB=\$PERL5LIB:$PERL5LIB:$PREFIX/lib/x86_64-linux-gnu/perl5/5.28:$PREFIX/share/perl/5.28.1:$PREFIX/lib/x86_64-linux-gnu/perl/5.28.1:$PREFIX/share/perl5"  | tee -a  $PREFIX/bin/start.sh
fi

if [ -e /project/start.sh ];then
    echo '[Custom Startup]'
    bash  /project/start.sh   | tee -a $PREFIX/bin/start.sh
fi
if [  -n "$CWD" ];then
    echo CWD="$CWD"
    echo "cd '$CWD'"  | tee -a  $PREFIX/bin/start.sh
fi

for i in `find "$PREFIX" -name "*.gschema.xml"|xargs -r dirname |uniq`;do
    echo Compile GLib schemas: $i
    glib-compile-schemas $i
    GSETTINGS_SCHEMA_DIR=$GSETTINGS_SCHEMA_DIR:$i
done

if [ -n "$GSETTINGS_SCHEMA_DIR" ];then
    echo "export GSETTINGS_SCHEMA_DIR=$GSETTINGS_SCHEMA_DIR"   | tee -a  $PREFIX/bin/start.sh
fi

QT_PLATFORM_PATH="$PREFIX/lib/x86_64-linux-gnu/qt5/platforms"
if [ -n "$SETUP_QPA" ];then
    mkdir -p $QT_PLATFORM_PATH 2>>/dev/nul
    cp -avf $ROOT/platforms/* $QT_PLATFORM_PATH
    chmod +x $QT_PLATFORM_PATH/*
    echo "export QT_QPA_PLATFORM_PLUGIN_PATH=$QT_PLATFORM_PATH"   | tee -a  $PREFIX/bin/start.sh
fi

QT_PLUGIN_PATH=`find $PREFIX/lib/x86_64-linux-gnu/qt5/plugins/ -name "*.so*"|xargs dirname|sort|uniq|paste -sd :`
if [ -n "$QT_PLUGIN_PATH" ];then
    echo "export QT_PLUGIN_PATH=$QT_PLUGIN_PATH"   | tee -a  $PREFIX/bin/start.sh
fi

QTWEBENGINE_RESOURCES_PATH="$PREFIX/share/qt5/resources"
if [ -d "$QTWEBENGINE_RESOURCES_PATH" ];then
    echo QTWEBENGINE_RESOURCES_PATH=$QTWEBENGINE_RESOURCES_PATH
    echo "export QTWEBENGINE_RESOURCES_PATH=$QTWEBENGINE_RESOURCES_PATH"   | tee -a $PREFIX/bin/start.sh
    ln -svf $QTWEBENGINE_RESOURCES_PATH/* $PREFIX/bin
    ln -svf $QTWEBENGINE_RESOURCES_PATH/* $PREFIX/lib/x86_64-linux-gnu/qt5/libexec/
fi

QTWEBENGINE_LOCALES_PATH="$PREFIX/share/qt5/translations/qtwebengine_locales" 
if [ -d "$QTWEBENGINE_LOCALES_PATH" ];then
    echo "export QTWEBENGINE_LOCALES_PATH=$QTWEBENGINE_LOCALES_PATH"  | tee -a  $PREFIX/bin/start.sh
    ln -svf $QTWEBENGINE_LOCALES_PATH $PREFIX/lib/x86_64-linux-gnu/qt5/libexec/
fi

QTWEBENGINEPROCESS_PATH="$PREFIX/lib/x86_64-linux-gnu/qt5/libexec/QtWebEngineProcess" 
if [ -e "$QTWEBENGINEPROCESS_PATH" ];then
    echo "export QTWEBENGINEPROCESS_PATH=$QTWEBENGINEPROCESS_PATH"  | tee -a  $PREFIX/bin/start.sh
fi
QML2_IMPORT_PATH="$PREFIX/lib/x86_64-linux-gnu/qt5/qml"
if [ -e "$QML2_IMPORT_PATH" ];then
    echo "export QML2_IMPORT_PATH=$QML2_IMPORT_PATH"  | tee -a  $PREFIX/bin/start.sh
fi

echo "$SHELL_BIN '$F_EXEC'" $F_ARGS "\$@"  | tee -a  $PREFIX/bin/start.sh
chmod +x $PREFIX/bin/start.sh

cd /project
if [ -e "$F_EXEC" ];then
    F_EXEC_ABS="$F_EXEC"
else
    F_EXEC_ABS="$F_DIR/$F_EXEC"
fi
if [ -z "$NO_PATCH_EXEC" ]&&[ -e "$F_EXEC_ABS" ] && ! objdump -a "$F_EXEC_ABS" 2>/dev/null ;then
    echo '[Patch Startup Script]'
    echo Target=$F_EXEC_ABS
    sed -E -i -e "s+/usr/bin/python+$PREFIX/bin/python+g" \
            -e "/[\w\!]\s*\/usr\//! s+/usr/share+$PREFIX/share+g" \
            -e "/[\w\!]\s*\/usr\//! s+/usr/+$PREFIX/+g" \
            -e "s+$PKG_NAME/entries+$LINGLONG_PKG_NAME/files/share+g" \
            -e "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g"  \
            "$F_EXEC_ABS"
fi

if [ -z "$NO_FIX_SYM" ];then
    echo '[Fix Symbol Link]'
    find $PREFIX -type l | while read -r SYMLINK; do
        TARGET=`readlink  "$SYMLINK"`
        TARGET_ABS=`readlink -f "$SYMLINK"`
        # if echo $TARGET|grep -q "$PKG_NAME/";then
        #     ln -svf $(echo  $TARGET|sed "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g") $SYMLINK
        # fi
        if echo $TARGET|grep -q "../opt/apps";then
            ln -svf `echo $TARGET|grep -oP "/opt/apps/.*"|sed "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g"`  "$SYMLINK"
        elif [ ! -e "$SYMLINK" ]&&[ -e "$PREFIX/$TARGET" ];then
            ln -svf "$PREFIX/$TARGET" "$SYMLINK"
        elif [ -d "$SYMLINK" ] && [ "$TARGET" != "$TARGET_ABS" ] || (echo $TARGET | grep -q "$PKG_NAME/");then
            ls -l $SYMLINK
            rm -vf "$SYMLINK"
            ln -svf `echo $TARGET_ABS|sed "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g"`  "$SYMLINK"
        fi

    done
fi

if [ -e "$PREFIX/lib/python3.7/ctypes/__init__.py" ];then
    echo '[Patch Python3.7 Ctypes Library]'
    sed -i 's/CFUNCTYPE(c_int)(lambda: None)/#CFUNCTYPE(c_int)(lambda: None)/g' $PREFIX/lib/python3.7/ctypes/__init__.py
fi
if [ -e "$PREFIX/lib/python2.7/ctypes/__init__.py" ];then
    echo '[Patch Python2.7 Ctypes Library]'
    sed -i 's/CFUNCTYPE(c_int)(lambda: None)/#CFUNCTYPE(c_int)(lambda: None)/g' $PREFIX/lib/python2.7/ctypes/__init__.py
fi


echo '[Self Test]'
rm /project/error.log 2>/dev/null
export PATH=$PATH:$PREFIX/bin:
if ! which "$F_EXEC";then
    echo BadExec=$F_EXEC | tee -a /project/error.log
fi
if [ -z `ls $PREFIX/share/applications/*.desktop` ];then
    echo NoExec=$PREFIX/share/applications/*.desktop | tee -a  /project/error.log
else

for i in `ls $PREFIX/share/applications/*.desktop`;do
    for icon in `cat $i|grep -P "^Icon"|sed -Ee 's/^Icon=//g'`;do
    if ! find $PREFIX/share/pixmaps $PREFIX/share/icons -name "$icon.*" | grep -qP "$icon\.\w+\$";then
        echo BadIcon=$i:$icon | tee -a /project/error.log
    fi
    if [ ! -e $PREFIX/share/icons/hicolor/scalable/apps/$icon.* ];then
        mkdir -p $PREFIX/share/icons/hicolor/scalable/apps 2>/dev/null
        cp -v `find "$PREFIX/share/icons" "$PREFIX/share/pixmaps" -name "$icon.*"|head -n 1` $PREFIX/share/icons/hicolor/scalable/apps
    fi
    done
done
fi


echo '[Fix Symbol Link]'
find $PREFIX -type l | while read -r SYMLINK; do
    TARGET=`readlink  "$SYMLINK"`
    TARGET_ABS=`readlink -f "$SYMLINK"`
    # if echo $TARGET|grep -q "$PKG_NAME/";then
    #     ln -svf $(echo  $TARGET|sed "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g") $SYMLINK
    # fi
    if echo $TARGET|grep -q "../opt/apps";then
        ln -svf `echo $TARGET|grep -oP "/opt/apps/.*"|sed "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g"`  "$SYMLINK"
    elif [ ! -e "$SYMLINK" ]&&[ -e "$PREFIX/$TARGET" ];then
        ln -svf "$PREFIX/$TARGET" "$SYMLINK"
    elif [ -d "$SYMLINK" ] && [ "$TARGET" != "$TARGET_ABS" ] || (echo $TARGET | grep -q "$PKG_NAME/");then
        rm -vf "$SYMLINK"
        ln -svf `echo $TARGET_ABS|sed "s+$PKG_NAME/+$LINGLONG_PKG_NAME/+g"`  "$SYMLINK"
    fi

done
if [ -e /project/post.sh ];then
    echo '[Post Build]'
    echo Exec /project/post.sh
    bash /project/post.sh
fi