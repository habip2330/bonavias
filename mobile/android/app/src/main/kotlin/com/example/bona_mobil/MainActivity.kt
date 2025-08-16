package com.bonavias.desserts

import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Facebook Key Hash'i logcat'e yazdır
        printKeyHash()
    }
    
    private fun printKeyHash() {
        try {
            val info = packageManager.getPackageInfo(
                "com.bonavias.desserts",
                PackageManager.GET_SIGNATURES
            )
            info.signatures?.let { signatures ->
                for (signature in signatures) {
                    val md = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val keyHash = Base64.encodeToString(md.digest(), Base64.DEFAULT)
                    Log.d("FacebookKeyHash", "Key Hash: $keyHash")
                    println("Facebook Key Hash: $keyHash")
                }
            }
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("FacebookKeyHash", "Package not found", e)
        } catch (e: NoSuchAlgorithmException) {
            Log.e("FacebookKeyHash", "Algorithm not found", e)
        }
    }
} 