package com.kirinpatel.myfridge.holders

import android.support.design.widget.FloatingActionButton
import android.support.v7.widget.CardView
import android.support.v7.widget.RecyclerView
import android.view.View
import android.widget.TextView
import com.kirinpatel.myfridge.R

class ItemViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    private val card: CardView = view.findViewById(R.id.card)
    private val itemTitle: TextView = view.findViewById(R.id.card_title)
    private val itemDescription: TextView = view.findViewById(R.id.card_description)
    private val itemMore: FloatingActionButton = view.findViewById(R.id.card_more)

    fun setTitle(title: String) {
        itemTitle.text = title
    }

    fun setDescription(description: String) {
        if (description.isEmpty())
            return

        itemDescription.text = description
        itemDescription.visibility = View.VISIBLE
    }

    fun setCardAction(action: View.OnClickListener) {
        card.setOnClickListener(action)
    }

    fun setMoreAction(action: View.OnClickListener) {
        itemMore.setOnClickListener(action)
    }

}