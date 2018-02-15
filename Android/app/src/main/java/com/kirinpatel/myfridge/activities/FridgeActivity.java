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
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.kirinpatel.myfridge.R;
import com.kirinpatel.myfridge.adapters.ItemAdapter;
import com.kirinpatel.myfridge.utils.Fridge;
import com.kirinpatel.myfridge.utils.Item;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class FridgeActivity extends AppCompatActivity {

    private FirebaseDatabase database = FirebaseDatabase.getInstance();
    private DatabaseReference ref = database.getReference();

    private Fridge fridge;

    private RecyclerView recyclerView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_fridge);

        recyclerView = findViewById(R.id.fridge_recyclerView);

        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        recyclerView.setLayoutManager(layoutManager);

        Intent intent = getIntent();
        loadFridge(intent.getStringExtra("key"));

        CollapsingToolbarLayout collapsingToolbarLayout = findViewById(R.id.fridge_collapsing);
        collapsingToolbarLayout.setTitle(intent.getStringExtra("name"));

        Toolbar toolbar = findViewById(R.id.fridge_toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        FloatingActionButton floatingActionButton = findViewById(R.id.fridge_floatingActionButton);
        floatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                addItem();
            }
        });
    }

    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_fridge, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.menu_fridge_edit) {
            editFridge();
            return true;
        } else if (id == R.id.menu_fridge_share) {
            shareFridge();
            return true;
        } else if (id == R.id.menu_fridge_delete) {
            deleteFridge();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void addItem() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Add item");

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);

        final EditText itemTitle = new EditText(this);
        itemTitle.setInputType(InputType.TYPE_CLASS_TEXT);
        itemTitle.setHint("Name");
        layout.addView(itemTitle);

        final EditText itemDescription = new EditText(this);
        itemDescription.setInputType(InputType.TYPE_CLASS_TEXT);
        itemDescription.setMinLines(1);
        itemDescription.setMaxLines(3);
        itemDescription.setHint("Description");
        layout.addView(itemDescription);

        builder.setView(layout);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                String name = itemTitle.getText().toString();
                String description = itemDescription.getText().toString();

                if (name.length() > 0) {
                    String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
                    String itemKey = ref.child(uid)
                            .child("fridges")
                            .child(fridge.getKey())
                            .child("items")
                            .push()
                            .getKey();

                    ref.child(uid)
                            .child("fridges")
                            .child(fridge.getKey())
                            .child("items")
                            .child(itemKey)
                            .child("name")
                            .setValue(name);
                    ref.child(uid)
                            .child("fridges")
                            .child(fridge.getKey())
                            .child("items")
                            .child(itemKey)
                            .child("description")
                            .setValue(description);
                } else {
                    Snackbar.make(
                            findViewById(R.id.coordinator),
                            "A name is required for an item!",
                            Snackbar.LENGTH_SHORT)
                            .show();
                }
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void editFridge() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Edit \"" + fridge.getName() + "\"?");
        builder.setMessage("You can change the name and description of this fridge.");

        builder.setPositiveButton("EDIT NAME", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                editName();
            }
        });
        builder.setNegativeButton("EDIT DESCRIPTION", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.cancel();
                editDescription();
            }
        });
        builder.setNeutralButton("CANCEL", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void editName() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Rename \"" + fridge.getName() + "\"");

        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        input.setText(fridge.getName());
        builder.setView(input);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                String name = input.getText().toString();
                if (name.length() > 0) {
                    ref.child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                            .child("fridges")
                            .child(fridge.getKey())
                            .child("name")
                            .setValue(name);
                    loadFridge(fridge.getKey());
                } else {
                    Snackbar.make(
                            findViewById(R.id.coordinator),
                            "A name is required for your fridge!",
                            Snackbar.LENGTH_SHORT)
                            .show();
                }
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void editDescription() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Change the description of \"" + fridge.getName() + "\"");

        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        input.setText(fridge.getDescription());
        builder.setView(input);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                ref.child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                        .child("fridges")
                        .child(fridge.getKey())
                        .child("description")
                        .setValue(input.getText().toString());
                loadFridge(fridge.getKey());
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void shareFridge() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Please enter UID of your family/" +
                "friend you want to share your fridge with/");
        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        input.setHint("UID");
        builder.setView(input);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                final String uid = input.getText().toString();

                if (uid.length() > 0
                        && !uid.equals(FirebaseAuth.getInstance().getCurrentUser().getUid())) {
                    Map<String, Object> map = new HashMap<>();
                    map.put(
                            fridge.getKey(),
                            FirebaseAuth.getInstance().getCurrentUser().getUid());

                    ref.child(uid)
                            .child("fridges").updateChildren(map);

                    Snackbar.make(
                            findViewById(R.id.coordinator),
                            "Your fridge has been shared!",
                            Snackbar.LENGTH_SHORT)
                            .show();
                } else {
                    Snackbar.make(
                            findViewById(R.id.coordinator),
                            "A UID is required to share your fridge!",
                            Snackbar.LENGTH_SHORT)
                            .show();
                }
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void deleteFridge() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Delete \"" + fridge.getName() + "\"?");
        builder.setMessage("You will be unable to recover your fridge if it is deleted.");

        builder.setPositiveButton("DELETE", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                ref.child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                        .child("fridges")
                        .child(fridge.getKey())
                        .removeValue();
                finish();
            }
        });
        builder.setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    private void loadFridge(final String key) {
        ref.child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                .child("fridges")
                .child(key)
                .addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                fridge = new Fridge(key, snapshot.child("name").getValue().toString());
                if (snapshot.child("description").exists()) {
                    fridge.setDescription(snapshot.child("description").getValue().toString());
                }

                CollapsingToolbarLayout collapsingToolbarLayout = findViewById(R.id.fridge_collapsing);
                collapsingToolbarLayout.setTitle(fridge.getName());

                loadItems();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });
    }

    private void loadItems() {
        final ProgressBar progressBar = findViewById(R.id.fridge_loadingIndicator);
        progressBar.setVisibility(View.VISIBLE);

        ref.child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                .child("fridges")
                .child(fridge.getKey())
                .child("items")
                .addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                ArrayList<Item> items = new ArrayList<>();

                for (DataSnapshot childSnapshot : snapshot.getChildren()) {
                    Item item = new Item(childSnapshot.getKey(),
                            childSnapshot.child("name").getValue().toString());
                    if (childSnapshot.child("description").exists()) {
                        item.setDescription(
                                childSnapshot.child("description").getValue().toString());
                    }
                    items.add(item);
                }

                recyclerView.setAdapter(new ItemAdapter(items, fridge.getKey()));
                progressBar.setVisibility(View.GONE);
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });
    }
}
