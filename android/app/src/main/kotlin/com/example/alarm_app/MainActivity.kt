package com.example.alarm_app

import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.content.Context
import android.media.AudioManager
import android.media.AudioManager.OnAudioFocusChangeListener
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val focusChangeListener = OnAudioFocusChangeListener { focusChange ->
        runOnUiThread {
            when (focusChange) {
                AudioManager.AUDIOFOCUS_GAIN -> {
                    Toast.makeText(this, "Audio focus gained", Toast.LENGTH_SHORT).show()
                }
                AudioManager.AUDIOFOCUS_LOSS -> {
                    Toast.makeText(this, "Audio focus lost", Toast.LENGTH_SHORT).show()
                }
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                    Toast.makeText(this, "Audio focus lost transiently", Toast.LENGTH_SHORT).show()
                }
                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                    Toast.makeText(this, "Audio focus lost transiently, can duck", Toast.LENGTH_SHORT).show()
                }
                AudioManager.AUDIOFOCUS_REQUEST_FAILED -> {
                    Toast.makeText(this, "Audio focus request failed", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    private lateinit var audioFocusRequest: AudioFocusRequest

    private val methodCallHandler = MethodChannel.MethodCallHandler { call, result ->
        when (call.method) {
            "requestAudioFocus" -> {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

                val audioAttributes = AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                        .setAudioAttributes(audioAttributes)
                        .setOnAudioFocusChangeListener(focusChangeListener)
                        .build()

                val res = audioManager.requestAudioFocus(audioFocusRequest)
                runOnUiThread {
                    Toast.makeText(this, "Audio focus requested", Toast.LENGTH_SHORT).show()
                }
                if (res == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                    runOnUiThread {
                        Toast.makeText(this, "Audio focus granted", Toast.LENGTH_SHORT).show()
                    }

                    result.success(true)
                } else {
                    runOnUiThread {
                        Toast.makeText(this, "Audio focus denied", Toast.LENGTH_SHORT).show()
                    }
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.alarm_app/audio")
                .setMethodCallHandler(methodCallHandler)
    }
}
