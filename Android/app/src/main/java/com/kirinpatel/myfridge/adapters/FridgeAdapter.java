package com.kirinpatel.myfridge.adapters;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.RecyclerView;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.kirinpatel.myfridge.R;
import com.kirinpatel.myfridge.activities.FridgeActivity;
import com.kirinpatel.myfridge.holders.FridgeViewHolder;
import com.kirinpatel.myfridge.utils.Fridge;

import java.util.ArrayList;

public class FridgeAdapter extends RecyclerView.Adapter<FridgeViewHolder> {

    private FirebaseDatabase database = FirebaseDatabase.getInstance();
    private DatabaseReference ref = database.getReference();
    private ArrayList<Fridge> fridges;

    public FridgeAdapter(ArrayList<Fridge> fridges) {
        this.fridges = fridges;
    }

    @Override
    public FridgeViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.card_fridge, parent,false);

        return new FridgeViewHolder(v);
    }

    @Override
    public void onBindViewHolder(final FridgeViewHolder holder, int position) {
        final Fridge fridge = fridges.get(position);

        holder.setTitle(fridge.getName());
        holder.setDescription(fridge.getDescription());
        holder.setCardAction(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(view.getContext(), FridgeActivity.class);
                intent.putExtra("key", fridge.getKey());
                intent.putExtra("name", fridge.getName());
                view.getContext().startActivity(intent);
            }
        });
        holder.setMoreAction(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showFridgeActions(view.getContext(), fridge);
            }
        });
    }

    @Override
    public int getItemCount() {
        return fridges.size();
    }

    private void showFridgeActions(final Context context, final Fridge fridge) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Edit \"" + fridge.getName() + "\"?");
        builder.setMessage("You can change the name and description or delete of this item.");

        builder.setPositiveButton("EDIT", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                editFridge(context, fridge);
            }
        });
        builder.setNegativeButton("DELETE", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.cancel();
                ref.child("fridges").child(fridge.getKey()).removeValue();
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

    private void editFridge(final Context context, final Fridge fridge) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Edit Fridge");

        LinearLayout layout = new LinearLayout(context);
        layout.setOrientation(LinearLayout.VERTICAL);

        final EditText itemTitle = new EditText(context);
        itemTitle.setInputType(InputType.TYPE_CLASS_TEXT);
        itemTitle.setHint("Name");
        itemTitle.setText(fridge.getName());
        layout.addView(itemTitle);

        final EditText itemDescription = new EditText(context);
        itemDescription.setInputType(InputType.TYPE_CLASS_TEXT);
        itemDescription.setMinLines(1);
        itemDescription.setMaxLines(3);
        itemDescription.setHint("Description");
        itemDescription.setText(fridge.getDescription());
        layout.addView(itemDescription);

        builder.setView(layout);

        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                String name = itemTitle.getText().toString();
                String description = itemDescription.getText().toString();

                if (name.length() > 0) {
                    ref.child("fridges")
                            .child(fridge.getKey())
                            .child("name")
                            .setValue(name);

                    ref.child("fridges")
                            .child(fridge.getKey())
                            .child("description")
                            .setValue(description);

                    fridge.setName(name);
                    fridge.setDescription(description);
                    FridgeAdapter.this.notifyDataSetChanged();
                } else {
                    Toast.makeText(
                            context,
                            "A name is required for an item!",
                            Toast.LENGTH_SHORT).show();
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
}