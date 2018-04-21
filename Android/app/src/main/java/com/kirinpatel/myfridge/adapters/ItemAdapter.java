package com.kirinpatel.myfridge.adapters;

import android.content.Context;
import android.content.DialogInterface;
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

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.kirinpatel.myfridge.R;
import com.kirinpatel.myfridge.holders.ItemViewHolder;
import com.kirinpatel.myfridge.utils.Item;

import java.util.ArrayList;

public class ItemAdapter extends RecyclerView.Adapter<ItemViewHolder> {

    private FirebaseDatabase database = FirebaseDatabase.getInstance();
    private DatabaseReference ref = database.getReference();
    private ArrayList<Item> items;
    private String fridgeKey;

    public ItemAdapter(ArrayList<Item> items, String fridgeKey) {
        this.items = items;
        this.fridgeKey = fridgeKey;
    }

    @Override
    public ItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.card_fridge, parent,false);

        return new ItemViewHolder(v);
    }

    @Override
    public void onBindViewHolder(final ItemViewHolder holder, int position) {
        final Item item = items.get(position);

        holder.setTitle(item.getName());
        holder.setDescription(item.getDescription());
        holder.setMoreAction(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showItemActions(view.getContext(), item);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private void showItemActions(final Context context, final Item item) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Edit \"" + item.getName() + "\"?");
        builder.setMessage("You can change the name and description or delete of this item.");

        builder.setPositiveButton("EDIT ITEM", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                editItem(context, item);
            }
        });
        builder.setNegativeButton("DELETE", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int i) {
                dialog.cancel();

                ref.child("fridges")
                        .child(fridgeKey)
                        .child("items")
                        .child(item.getKey())
                        .removeValue();
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

    private void editItem(final Context context, final Item item) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Edit Item");

        LinearLayout layout = new LinearLayout(context);
        layout.setOrientation(LinearLayout.VERTICAL);

        final EditText itemTitle = new EditText(context);
        itemTitle.setInputType(InputType.TYPE_CLASS_TEXT);
        itemTitle.setHint("Name");
        itemTitle.setText(item.getName());
        layout.addView(itemTitle);

        final EditText itemDescription = new EditText(context);
        itemDescription.setInputType(InputType.TYPE_CLASS_TEXT);
        itemDescription.setMinLines(1);
        itemDescription.setMaxLines(3);
        itemDescription.setHint("Description");
        itemDescription.setText(item.getDescription());
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
                            .child(fridgeKey)
                            .child("items")
                            .child(item.getKey())
                            .child("name")
                            .setValue(name);

                    ref.child("fridges")
                            .child(fridgeKey)
                            .child("items")
                            .child(item.getKey())
                            .child("description")
                            .setValue(description);

                    item.setName(name);
                    item.setDescription(description);
                    ItemAdapter.this.notifyDataSetChanged();
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