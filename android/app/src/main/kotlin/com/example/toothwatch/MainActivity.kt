package com.example.toothwatch

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val FLUTTER_CHANNEL = "com.example.toothwatch/timer";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL).setMethodCallHandler {
            call, result ->
                if (call.method == "startTimerService") {
                    startTimerService(call.argument("secondsElapsed") ?: 0.0);
                    result.success(null);
                } else if (call.method == "retrieveTimerSecondsAndClose") {
                    val timerSeconds = retrieveTimerSecondsAndClose()
                    result.success(timerSeconds)
                } else {
                    result.notImplemented()
                }
        }
    }

    private fun startTimerService(secondsElapsed: Double) {
        val service = Intent(this, TimerService::class.java)
        // TODO - add unix epoch extra
        service.putExtra(TimerService.START_SECONDS_EXTRA, (secondsElapsed * 1L))
        startService(service)
        bindService(service, connection, Context.BIND_IMPORTANT or Context.BIND_AUTO_CREATE)
    }

    private fun retrieveTimerSecondsAndClose() : Double {
        val timerService = connection.timerService
        val timerSeconds = timerService?.getElapsedSeconds() ?: -1.0;
        if (timerService != null) {
            val service = Intent(this, TimerService::class.java)
            unbindService(connection)
            stopService(service)
        }
        return timerSeconds
    }

    private val connection = object : ServiceConnection {
        var timerService: TimerService? = null;

        override fun onServiceConnected(className: ComponentName?,
                                        service: IBinder) {
            val binder = service as TimerService.TimerBinder
            timerService = binder.getService()
            //Log.i(TAG, "Service connected")
        }

        override fun onServiceDisconnected(arg0: ComponentName?) {
            timerService = null;
            //Log.i(TAG, "Service disconnected")
        }
    }
}
