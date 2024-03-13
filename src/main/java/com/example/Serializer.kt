package com.example;

import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream

import java.net.Socket;

fun deserialize(sock: Socket) {
    ObjectInputStream(sock.getInputStream()).use { it ->
        val test = it.readObject()
    }
}

fun main(args : Array<String>){
    //Destination File
    val file = "belchers.burgers"

    //A map of family
    val family = mapOf(
            "Bob" to "Father",
            "Linda" to "Mother",
            "Tina" to "Oldest",
            "Gene" to "Middle",
            "Louise" to "Youngest")

    //Write the family map object to a file
    ObjectOutputStream(FileOutputStream(file)).use{ it -> it.writeObject(family)}

    println("Wrote $file")
    println()
    println("Time to read $file back")

    //Now time to read the family back into memory
    ObjectInputStream(FileInputStream(file)).use { it ->
        //Read the family back from the file
        val restedFamily = it.readObject()

        //Cast it back into a Map
        when (restedFamily) {
            //We can't use <String, String> because of type erasure
            is Map<*, *> -> println(restedFamily)
            else -> println("Deserialization failed")
        }
    }
}
