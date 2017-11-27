# Thanks @djacobs https://gist.github.com/djacobs/2411095

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"
RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

echo "********************"
echo "*     Signing      *"
echo "********************"

RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

mkdir -p "$OUTPUTDIR/Payload"
cp -R "$OUTPUTDIR/$APP_NAME.app" "$OUTPUTDIR/Payload/"
cd "$OUTPUTDIR"
#zip -r -s 64 Payload.zip Payload/
zip -r "Payload.zip" "Payload"
zip -r -9 "$APP_NAME.app.dSYM.zip" "$APP_NAME.app.dSYM"


ls "$OUTPUTDIR"
echo "** **"
mv "$OUTPUTDIR/Payload.zip" "$OUTPUTDIR/$APP_NAME.ipa"
ls "$OUTPUTDIR"

echo "** **"
  
curl https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions \
  -F status="2" \
  -F notify="0" \
  -F notes="$RELEASE_NOTES" \
  -F notes_type="0" \
  -F ipa="@$OUTPUTDIR/$APP_NAME.ipa" \
  -F dsym="@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" \
  -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"
  
  echo "** build completed **"


ipa distribute:itunesconnect \
 —-file "$OUTPUTDIR/$APP_NAME.ipa" \
 —-account michael.rieger95@gmail.com \
 -p Uwodeveva920 \
 —-apple-id 1188620534 —-upload —-verbose