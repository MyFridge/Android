package com.kirinpatel.myfridge.activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.InputType;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.kirinpatel.myfridge.R;
import com.kirinpatel.myfridge.utils.Fridge;
import com.kirinpatel.myfridge.adapters.FridgeAdapter;

import java.util.ArrayList;

public class HomeActivity extends AppCompatActivity {

    private FirebaseUser user;
    private FirebaseDatabase database = FirebaseDatabase.getInstance();
    private DatabaseReference ref = database.getReference();

    private RecyclerView recyclerView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_home);

        recyclerView = findViewById(R.id.home_recyclerView);

        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        recyclerView.setLayoutManager(layoutManager);

        loadUser();

        Intent intent = getIntent();
        displayOnBoarding(intent.getBooleanExtra("isNew", false));

        CollapsingToolbarLayout collapsingToolbarLayout = findViewById(R.id.main_collapsing);
        collapsingToolbarLayout.setTitle("MyFridge");

        Toolbar toolbar = findViewById(R.id.main_toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton addFAB = findViewById(R.id.home_floatingActionButton);
        addFAB.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                createFridge();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (recyclerView != null) {
            loadFridges();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_home, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.profile) {
            Intent intent = new Intent(this, ProfileActivity.class);
            startActivity(intent);
            return true;
        }/* else if (id == R.id.settings) {
            return true;
        } */else if (id == R.id.logout) {
            FirebaseAuth.getInstance().signOut();
            finish();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void loadUser() {
        user = FirebaseAuth.getInstance().getCurrentUser();

        if (user != null) {
            loadFridges();
        } else {
            finish();
        }
    }

    private void displayOnBoarding(boolean shouldDisplay) {
        if (shouldDisplay) {
            displayWelcomeMessage();
        }
    }

    private void displayWelcomeMessage() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Welcome " + user.getDisplayName());
        builder.setMessage("MyFridge is currently under development, " +
                "this means that only certain " +
                "features are available and they may be buggy.");

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void loadFridges() {
        final ProgressBar progressBar = findViewById(R.id.home_loadingIndicator);
        progressBar.setVisibility(View.VISIBLE);

        final ArrayList<Fridge> fridges = new ArrayList<>();

        ref.child("users")
                .child(user.getUid())
                .child("fridges")
                .addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                if (snapshot.getChildrenCount() == 0) {
                    progressBar.setVisibility(View.GONE);
                }

                for (final DataSnapshot childSnapshot : snapshot.getChildren()) {
                    ref.child("fridges")
                            .child(childSnapshot.getValue().toString())
                            .addListenerForSingleValueEvent(new ValueEventListener() {
                                @Override
                                public void onDataChange(DataSnapshot childChildSnapshot) {
                                    if (childChildSnapshot.exists()) {
                                        Fridge fridge = new Fridge(
                                                childChildSnapshot.getKey(),
                                                childChildSnapshot.child("name")
                                                        .getValue()
                                                        .toString());


                                        if (childChildSnapshot.child("description").exists()) {
                                            fridge.setDescription(
                                                    childChildSnapshot
                                                            .child("description")
                                                            .getValue()
                                                            .toString());
                                        }

                                        fridges.add(fridge);

                                        recyclerView.setAdapter(new FridgeAdapter(fridges));
                                    } else {
                                        ref.child("users")
                                                .child(user.getUid())
                                                .child("fridges")
                                                .child(childSnapshot.getKey())
                                                .removeValue();
                                    }

                                    progressBar.setVisibility(View.GONE);
                                }

                                @Override
                                public void onCancelled(DatabaseError databaseError) {

                                }
                            });
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });
    }

    private void createFridge() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Please enter the name of your fridge");

        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                String fridgeKey = ref.child("fridges")
                        .push()
                        .getKey();
                String pushKey = ref.child("users")
                        .child(user.getUid())
                        .child("fridges")
                        .push()
                        .getKey();
                String name = input.getText().toString();
                if (name.length() == 0) {
                    Snackbar.make(
                            findViewById(R.id.coordinator),
                            "A fridge must have a name!",
                            Snackbar.LENGTH_SHORT)
                            .show();
                    createFridge();
                } else {
                    ref.child("fridges")
                            .child(fridgeKey)
                            .child("name")
                            .setValue(name);
                    ref.child("users")
                            .child(user.getUid())
                            .child("fridges")
                            .child(pushKey)
                            .setValue(fridgeKey);
                    loadFridges();
                }
            }
        }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        }).show();
    }
}
