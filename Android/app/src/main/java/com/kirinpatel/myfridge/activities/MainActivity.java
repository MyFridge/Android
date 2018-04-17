package com.kirinpatel.myfridge.activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.text.InputType;
import android.text.method.PasswordTransformationMethod;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.kirinpatel.myfridge.R;

import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {

    private FirebaseAuth mAuth;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        mAuth = FirebaseAuth.getInstance();

        Button emailSign = findViewById(R.id.signInWithEmail);
        emailSign.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                displayEmailRequestDialog();
            }
        });

        Button phoneSignIn = findViewById(R.id.signInWithPhone);
        phoneSignIn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                displayPhoneRequestDialog();
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();

        checkForUser();
    }

    private void checkForUser() {
        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user != null) {
            Intent intent;

            if (user.getDisplayName() != null && user.getDisplayName().length() != 0) {
                intent = new Intent(MainActivity.this, HomeActivity.class);
            } else {
                intent = new Intent(MainActivity.this, OnBoarding.class);
            }

            startActivity(intent);
        }
    }

    private void displayEmailRequestDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Sign in With Your Email Address");
        builder.setMessage("If you do not already have an account one will be made for you.");

        LinearLayout layout = new LinearLayout(builder.getContext());
        layout.setOrientation(LinearLayout.VERTICAL);

        final EditText email = new EditText(this);
        email.setHint("Email Address");
        email.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        layout.addView(email);

        final EditText password = new EditText(this);
        password.setHint("Password");
        password.setInputType(InputType.TYPE_TEXT_VARIATION_PASSWORD);
        password.setTransformationMethod(PasswordTransformationMethod.getInstance());
        layout.addView(password);

        builder.setView(layout);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                verifyEmail(email.getText().toString(), password.getText().toString());
            }
        }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        }).show();
    }

    private void displayPhoneRequestDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Sign in With Your Phone Number");

        final EditText phone = new EditText(this);
        phone.setInputType(InputType.TYPE_CLASS_PHONE);
        builder.setView(phone);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                sendPhoneVerification(phone.getText().toString());
            }
        }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        }).show();
    }

    private void displayPhoneVerificationDialog(final String verificationId) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Please Enter your Verification Code");

        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_NUMBER);
        builder.setView(input);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                signInWithPhone(PhoneAuthProvider.getCredential(verificationId,
                        input.getText().toString()));
            }
        }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        }).show();
    }

    private void verifyEmail(final String email, final String password) {
        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
            @Override
            public void onComplete(@NonNull Task<AuthResult> task) {
                if (task.isSuccessful()) {
                    checkForUser();
                } else if (task.getException()
                        .getLocalizedMessage()
                        .equals("The email address is already in use by another account.")) {
                    mAuth.signInWithEmailAndPassword(email, password)
                            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if (task.isSuccessful()) {
                                checkForUser();
                            } else {
                                Snackbar.make(
                                        findViewById(R.id.coordinator),
                                        task.getException().getLocalizedMessage(),
                                        Snackbar.LENGTH_SHORT)
                                        .show();
                            }
                        }
                    });
                } else {
                    Snackbar.make(
                            findViewById(R.id.coordinator),
                            task.getException().getLocalizedMessage(),
                            Snackbar.LENGTH_SHORT)
                            .show();
                }
            }
        });
    }

    private void sendPhoneVerification(String phoneNumber) {
        PhoneAuthProvider.getInstance().verifyPhoneNumber(
                phoneNumber,
                60,
                TimeUnit.SECONDS,
                this,
                new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {

                    @Override
                    public void onVerificationCompleted(PhoneAuthCredential credential) {

                    }

                    @Override
                    public void onVerificationFailed(FirebaseException e) {
                        Snackbar.make(
                                findViewById(R.id.coordinator),
                                e.getLocalizedMessage(),
                                Snackbar.LENGTH_SHORT)
                                .show();
                    }

                    @Override
                    public void onCodeSent(String verificationId,
                                           PhoneAuthProvider.ForceResendingToken token) {
                        displayPhoneVerificationDialog(verificationId);
                    }
                });
    }

    private void signInWithPhone(PhoneAuthCredential credential) {
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            checkForUser();
                        } else {
                            if (task.getException() instanceof
                                    FirebaseAuthInvalidCredentialsException) {
                                Snackbar.make(
                                        findViewById(R.id.coordinator),
                                        task.getException().getLocalizedMessage(),
                                        Snackbar.LENGTH_SHORT)
                                        .show();
                            }
                        }
                    }
                });
    }
}
