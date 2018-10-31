ADB=adb
$ADB shell am broadcast -a com.android.systemui.demo '--es' 'command' 'enter'
$ADB shell am broadcast -a com.android.systemui.demo '--es' 'command' 'clock' '--es' 'hhmm' '0900'
$ADB shell am broadcast -a com.android.systemui.demo '--es' 'command' 'battery' '--es' 'level' '100' '--es' 'plugged' 'false'
$ADB shell am broadcast -a com.android.systemui.demo '--es' 'command' 'notifications' '--es' 'visible' 'false'
