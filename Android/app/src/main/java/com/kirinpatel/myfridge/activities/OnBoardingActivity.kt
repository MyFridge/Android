package com.kirinpatel.myfridge.activities

import android.content.Intent
import android.os.Bundle
import android.support.design.widget.Snackbar
import android.support.v7.app.AppCompatActivity
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.UserProfileChangeRequest
import com.google.firebase.database.FirebaseDatabase
import com.kirinpatel.myfridge.R

open class OnBoardingActivity : AppCompatActivity() {
    private var user: FirebaseUser? = null
    private val database = FirebaseDatabase.getInstance()
    private val ref = database.reference

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_on_boarding)

        val displayName = findViewById<EditText>(R.id.displayName)
        val next = findViewById<Button>(R.id.next)
        next.setOnClickListener { setName(displayName.text.toString()) }
    }

    override fun onStart() {
        super.onStart()

        user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            finish()
        }
    }

    private fun setName(name: String) {
        if (name.isEmpty()) {
            Toast.makeText(applicationContext,
                    "Please provide your name!", Toast.LENGTH_SHORT).show()
        } else {
            val profileUpdates = UserProfileChangeRequest.Builder()
                    .setDisplayName(name)
                    .build()

            user!!.updateProfile(profileUpdates)
                    .addOnCompleteListener { task ->
                        if (task.isSuccessful) {
                            ref.child("users")
                                    .child(user!!.uid)
                                    .child("name")
                                    .setValue(name)
                            val intent = Intent(applicationContext,
                                    HomeActivity::class.java)
                            intent.putExtra("isNew", true)
                            startActivity(intent)
                            finish()
                        } else {
                            Snackbar.make(
                                    findViewById(R.id.coordinator),
                                    "Error setting name: " + task.exception!!.localizedMessage,
                                    Snackbar.LENGTH_SHORT)
                                    .show()
                        }
                    }
        }
    }
}