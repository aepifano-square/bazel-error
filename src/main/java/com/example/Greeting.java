package com.example;

import java.net.Socket;
import java.io.ObjectInputStream;

public class Greeting {
    public static void sayHi() {
        System.out.println("Hi!");
    }

    public static class MyObject {
		public int field;
		MyObject(int field) {
		    this.field = field;
		}
	}

    public static MyObject deserialize(Socket sock) throws Exception {
        try(ObjectInputStream in = new ObjectInputStream(sock.getInputStream())) {
            return (MyObject)in.readObject(); // unsafe
        }
    }
}
