package com.example.ledionpana_message_checker;

import java.io.IOException;

public class ApiService {
    public static boolean testConnection(String url) {
        return HttpHelper.testUrl(url);
    }

    public static int sendMessage(String url, String json) throws IOException {
        return HttpHelper.sendPost(url, json);
    }
}
