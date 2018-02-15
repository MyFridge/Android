package com.kirinpatel.myfridge.adapters;

import android.content.Intent;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.kirinpatel.myfridge.R;
import com.kirinpatel.myfridge.activities.FridgeActivity;
import com.kirinpatel.myfridge.utils.Fridge;

import java.util.ArrayList;

public class FridgeAdapter extends RecyclerView.Adapter<FridgeAdapter.ViewHolder> {

    private ArrayList<Fridge> fridges;

    public static class ViewHolder extends RecyclerView.ViewHolder {

        public TextView fridgeTitle;
        public TextView fridgeDescription;
        public FloatingActionButton fridgeMore;

        public ViewHolder(View view) {
            super(view);
            fridgeTitle = view.findViewById(R.id.card_title);
            fridgeDescription = view.findViewById(R.id.card_description);
            fridgeMore = view.findViewById(R.id.card_more);
        }
    }

    public FridgeAdapter(ArrayList<Fridge> fridges) {
        this.fridges = fridges;
    }

    @Override
    public FridgeAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.card_fridge, parent,false);

        ViewHolder vh = new ViewHolder(v);
        return vh;
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {
        final Fridge fridge = fridges.get(position);

        holder.fridgeTitle.setText(fridge.getName());
        if (fridge.getDescription().length() != 0) {
            holder.fridgeDescription.setVisibility(View.VISIBLE);
            holder.fridgeDescription.setText(fridge.getDescription());
        }
        holder.fridgeMore.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(view.getContext(), FridgeActivity.class);
                intent.putExtra("key", fridge.getKey());
                intent.putExtra("name", fridge.getName());
                view.getContext().startActivity(intent);
            }
        });
    }

    @Override
    public int getItemCount() {
        return fridges.size();
    }
}