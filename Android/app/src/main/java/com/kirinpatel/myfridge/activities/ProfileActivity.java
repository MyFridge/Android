package com.kirinpatel.myfridge.activities;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
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

public class ProfileActivity extends AppCompatActivity {

    private final String TAG = "PROFILE_ACTIVITY";

    FirebaseDatabase database = FirebaseDatabase.getInstance();
    DatabaseReference ref = database.getReference();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_profile);

        Toolbar toolbar = findViewById(R.id.toolbar);
        toolbar.setTitle("My Profile");
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        final FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();

        final EditText name = findViewById(R.id.profile_name);
        name.setText(user.getDisplayName());
        name.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                final String newName = name.getText().toString();
                if (newName.length() > 0) {
                    UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
                            .setDisplayName(newName)
                            .build();

                    user.updateProfile(profileUpdates)
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if (task.isSuccessful()) {
                                        Log.d(TAG, "updateProfile:success");

                                        ref.child(user.getUid()).child("name").setValue(newName);
                                    } else {
                                        Log.w(
                                                TAG,
                                                "updateProfile:failure",
                                                task.getException());
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
        });

        EditText uid = findViewById(R.id.profile_uid);
        uid.setText(user.getUid());
        uid.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ClipboardManager clipboard =
                        (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                ClipData clip = ClipData.newPlainText("UID", user.getUid());
                clipboard.setPrimaryClip(clip);

                Toast.makeText(
                        getApplicationContext(),
                        "Your UID has been copied!",
                        Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }
}
