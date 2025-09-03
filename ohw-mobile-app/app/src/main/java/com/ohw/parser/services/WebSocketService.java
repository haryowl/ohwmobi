package com.ohw.parser.services;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import java.net.InetSocketAddress;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import com.ohw.parser.models.ParsedPacket;
import com.google.gson.Gson;

public class WebSocketService extends Service {

    private static final String TAG = "WebSocketService";
    private static final int WS_PORT = 3002;
    
    private final AtomicBoolean isRunning = new AtomicBoolean(false);
    private final ConcurrentHashMap<String, WebSocket> connectedClients = new ConcurrentHashMap<>();
    private final Gson gson = new Gson();
    
    private WebSocketServer webSocketServer;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "WebSocket Service created");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "WebSocket Service starting...");
        
        if (isRunning.compareAndSet(false, true)) {
            startWebSocketServer();
        }
        
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void startWebSocketServer() {
        webSocketServer = new WebSocketServer(new InetSocketAddress(WS_PORT)) {
            @Override
            public void onOpen(WebSocket conn, ClientHandshake handshake) {
                String clientId = conn.getRemoteSocketAddress().toString();
                connectedClients.put(clientId, conn);
                Log.i(TAG, "WebSocket client connected: " + clientId);
                Log.i(TAG, "Total WebSocket clients: " + connectedClients.size());
                
                // Send initial data to new client
                sendInitialData(conn);
            }

            @Override
            public void onClose(WebSocket conn, int code, String reason, boolean remote) {
                String clientId = conn.getRemoteSocketAddress().toString();
                connectedClients.remove(clientId);
                Log.i(TAG, "WebSocket client disconnected: " + clientId);
                Log.i(TAG, "Remaining WebSocket clients: " + connectedClients.size());
            }

            @Override
            public void onMessage(WebSocket conn, String message) {
                Log.i(TAG, "WebSocket message received: " + message);
                handleWebSocketMessage(conn, message);
            }

            @Override
            public void onError(WebSocket conn, Exception ex) {
                Log.e(TAG, "WebSocket error", ex);
            }

            @Override
            public void onStart() {
                Log.i(TAG, "WebSocket server started on port " + WS_PORT);
            }
        };
        
        webSocketServer.start();
    }

    private void sendInitialData(WebSocket conn) {
        try {
            // Send server status and basic info
            String initialData = gson.toJson(new ServerStatus("connected", "OHW Parser Mobile"));
            conn.send(initialData);
        } catch (Exception e) {
            Log.e(TAG, "Error sending initial data", e);
        }
    }

    private void handleWebSocketMessage(WebSocket conn, String message) {
        try {
            // Parse message and handle different types
            if (message.contains("get_status")) {
                sendServerStatus(conn);
            } else if (message.contains("get_devices")) {
                sendDeviceList(conn);
            } else if (message.contains("send_command")) {
                handleCommandRequest(conn, message);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error handling WebSocket message", e);
        }
    }

    private void sendServerStatus(WebSocket conn) {
        try {
            ServerStatus status = new ServerStatus("running", "OHW Parser Mobile");
            conn.send(gson.toJson(status));
        } catch (Exception e) {
            Log.e(TAG, "Error sending server status", e);
        }
    }

    private void sendDeviceList(WebSocket conn) {
        try {
            // This would get device data from TcpServerService
            // For now, send empty list
            DeviceListResponse response = new DeviceListResponse();
            conn.send(gson.toJson(response));
        } catch (Exception e) {
            Log.e(TAG, "Error sending device list", e);
        }
    }

    private void handleCommandRequest(WebSocket conn, String message) {
        try {
            // Parse command request and forward to TCP service
            // This would integrate with the command system
            CommandResponse response = new CommandResponse("received", "Command queued");
            conn.send(gson.toJson(response));
        } catch (Exception e) {
            Log.e(TAG, "Error handling command request", e);
        }
    }

    public void broadcastDeviceData(ParsedPacket packet) {
        if (connectedClients.isEmpty()) {
            return;
        }
        
        try {
            String deviceData = gson.toJson(packet);
            Log.i(TAG, "Broadcasting device data to " + connectedClients.size() + " clients");
            
            for (WebSocket client : connectedClients.values()) {
                if (client.isOpen()) {
                    client.send(deviceData);
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error broadcasting device data", e);
        }
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "WebSocket Service destroying...");
        isRunning.set(false);
        
        if (webSocketServer != null) {
            webSocketServer.stop();
        }
        
        super.onDestroy();
    }

    // Data classes for JSON responses
    private static class ServerStatus {
        public String status;
        public String name;
        
        public ServerStatus(String status, String name) {
            this.status = status;
            this.name = name;
        }
    }
    
    private static class DeviceListResponse {
        public String[] devices = new String[0];
        public int count = 0;
    }
    
    private static class CommandResponse {
        public String status;
        public String message;
        
        public CommandResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}
