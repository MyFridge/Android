package com.kirinpatel.myfridge.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.kirinpatel.myfridge.R;

public class OnBoarding extends AppCompatActivity {

    private final String TAG = "ON_BOARDING_ACTIVITY";

    private FirebaseUser user;
    FirebaseDatabase database = FirebaseDatabase.getInstance();
    DatabaseReference ref = database.getReference();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_on_boarding);

        final EditText displayName = findViewById(R.id.displayName);
        Button next = findViewById(R.id.next);
        next.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setName(displayName.getText().toString());
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();

        user = FirebaseAuth.getInstance().getCurrentUser();
        if (user != null) {
            Log.d(TAG, "userIsSignedIn:true");
        } else {
            Log.d(TAG, "userIsSignedIn:false");
            finish();
        }
    }

    private void setName(final String name) {
        if (name.length() == 0) {
            Toast.makeText(getApplicationContext(),
                    "Please provide your name!", Toast.LENGTH_SHORT).show();
        } else {
            UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
                    .setDisplayName(name)
                    .build();

            user.updateProfile(profileUpdates)
                    .addOnCompleteListener(new OnCompleteListener<Void>() {
                        @Override
                        public void onComplete(@NonNull Task<Void> task) {
                            if (task.isSuccessful()) {
                                Log.d(TAG, "updateProfile:success");

                                ref.child(user.getUid()).child("name").setValue(name);
                                Intent intent = new Intent(getApplicationContext(),
                                        HomeActivity.class);
                                intent.putExtra("isNew", true);
                                startActivity(intent);
                                finish();
                            } else {
                                Log.w(TAG, "updateProfile:failure", task.getException());
                                Snackbar.make(
                                        findViewById(R.id.coordinator),
                                        "Error setting name: "
                                                + task.getException().getLocalizedMessage(),
                                        Snackbar.LENGTH_SHORT)
                                        .show();
                            }
                        }
                    });
        }
    }
}
