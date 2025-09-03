package com.ohw.parser.services;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.ohw.parser.MainActivity;
import com.ohw.parser.R;
import com.ohw.parser.parsers.GalileoskyParser;
import com.ohw.parser.models.DeviceData;
import com.ohw.parser.models.ParsedPacket;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketAddress;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;

public class TcpServerService extends Service {

    private static final String TAG = "TcpServerService";
    private static final String CHANNEL_ID = "OHW_PARSER_CHANNEL";
    private static final int NOTIFICATION_ID = 1001;
    
    // Server configuration
    private static final int TCP_PORT = 3000;
    private static final int HTTP_PORT = 3001;
    private static final int SOCKET_TIMEOUT = 30000; // 30 seconds
    
    // Server state
    private ServerSocket tcpServer;
    private ServerSocket httpServer;
    private final AtomicBoolean isRunning = new AtomicBoolean(false);
    private final ExecutorService executorService = Executors.newCachedThreadPool();
    
    // Device tracking
    private final ConcurrentHashMap<String, DeviceData> devices = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Socket, String> deviceConnections = new ConcurrentHashMap<>();
    
    // Parser
    private final GalileoskyParser parser = new GalileoskyParser();
    
    // WebSocket service reference
    private WebSocketService webSocketService;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        Log.i(TAG, "TCP Server Service created");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "TCP Server Service starting...");
        
        if (isRunning.compareAndSet(false, true)) {
            startForeground(NOTIFICATION_ID, createNotification());
            startServers();
        }
        
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void startServers() {
        // Start TCP server in background thread
        executorService.submit(() -> {
            try {
                startTcpServer();
            } catch (Exception e) {
                Log.e(TAG, "Error starting TCP server", e);
            }
        });
        
        // Start HTTP server in background thread
        executorService.submit(() -> {
            try {
                startHttpServer();
            } catch (Exception e) {
                Log.e(TAG, "Error starting HTTP server", e);
            }
        });
    }

    private void startTcpServer() throws IOException {
        tcpServer = new ServerSocket(TCP_PORT);
        Log.i(TAG, "TCP Server started on port " + TCP_PORT);
        
        while (isRunning.get()) {
            try {
                Socket clientSocket = tcpServer.accept();
                Log.i(TAG, "New device connected: " + clientSocket.getRemoteSocketAddress());
                
                // Handle client connection in separate thread
                executorService.submit(() -> handleClientConnection(clientSocket));
                
            } catch (IOException e) {
                if (isRunning.get()) {
                    Log.e(TAG, "Error accepting TCP connection", e);
                }
            }
        }
    }

    private void startHttpServer() throws IOException {
        httpServer = new ServerSocket(HTTP_PORT);
        Log.i(TAG, "HTTP Server started on port " + HTTP_PORT);
        
        while (isRunning.get()) {
            try {
                Socket clientSocket = httpServer.accept();
                Log.i(TAG, "New HTTP client connected: " + clientSocket.getRemoteSocketAddress());
                
                // Handle HTTP client in separate thread
                executorService.submit(() -> handleHttpConnection(clientSocket));
                
            } catch (IOException e) {
                if (isRunning.get()) {
                    Log.e(TAG, "Error accepting HTTP connection", e);
                }
            }
        }
    }

    private void handleClientConnection(Socket clientSocket) {
        try {
            clientSocket.setSoTimeout(SOCKET_TIMEOUT);
            InputStream inputStream = clientSocket.getInputStream();
            OutputStream outputStream = clientSocket.getOutputStream();
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            
            while (isRunning.get() && !clientSocket.isClosed()) {
                bytesRead = inputStream.read(buffer);
                if (bytesRead == -1) {
                    break; // Connection closed by client
                }
                
                if (bytesRead > 0) {
                    // Process received data
                    byte[] data = new byte[bytesRead];
                    System.arraycopy(buffer, 0, data, 0, bytesRead);
                    
                    Log.i(TAG, "Raw data received from " + clientSocket.getRemoteSocketAddress() + 
                          ": " + bytesToHex(data));
                    
                    // Parse and process packet
                    processPacket(data, clientSocket, outputStream);
                }
            }
            
        } catch (IOException e) {
            Log.e(TAG, "Error handling client connection", e);
        } finally {
            handleClientDisconnection(clientSocket);
        }
    }

    private void handleHttpConnection(Socket clientSocket) {
        try {
            // Simple HTTP response for now
            String response = "HTTP/1.1 200 OK\r\n" +
                            "Content-Type: text/plain\r\n" +
                            "Content-Length: 13\r\n" +
                            "\r\n" +
                            "OHW Parser OK";
            
            OutputStream outputStream = clientSocket.getOutputStream();
            outputStream.write(response.getBytes());
            outputStream.flush();
            
        } catch (IOException e) {
            Log.e(TAG, "Error handling HTTP connection", e);
        } finally {
            try {
                clientSocket.close();
            } catch (IOException e) {
                Log.e(TAG, "Error closing HTTP client socket", e);
            }
        }
    }

    private void processPacket(byte[] data, Socket clientSocket, OutputStream outputStream) {
        try {
            // Parse packet using Galileosky parser
            ParsedPacket parsedPacket = parser.parsePacket(data);
            
            if (parsedPacket != null) {
                // Extract IMEI and update device tracking
                String imei = parsedPacket.getImei();
                if (imei != null) {
                    updateDeviceTracking(imei, clientSocket.getRemoteSocketAddress());
                    deviceConnections.put(clientSocket, imei);
                }
                
                // Send confirmation packet
                byte[] confirmation = buildConfirmationPacket(data);
                outputStream.write(confirmation);
                outputStream.flush();
                
                Log.i(TAG, "Packet processed successfully from " + clientSocket.getRemoteSocketAddress());
                
                // Emit data to WebSocket clients if available
                if (webSocketService != null) {
                    webSocketService.broadcastDeviceData(parsedPacket);
                }
            }
            
        } catch (Exception e) {
            Log.e(TAG, "Error processing packet", e);
        }
    }

    private void updateDeviceTracking(String imei, SocketAddress clientAddress) {
        DeviceData deviceData = devices.computeIfAbsent(imei, k -> new DeviceData(imei));
        deviceData.updateLastSeen();
        deviceData.incrementRecordCount();
        deviceData.setClientAddress(clientAddress.toString());
        
        Log.i(TAG, "Device " + imei + " updated: " + deviceData.getTotalRecords() + " total records");
    }

    private void handleClientDisconnection(Socket clientSocket) {
        String imei = deviceConnections.remove(clientSocket);
        if (imei != null) {
            Log.i(TAG, "Device " + imei + " disconnected from " + clientSocket.getRemoteSocketAddress());
        }
        
        try {
            clientSocket.close();
        } catch (IOException e) {
            Log.e(TAG, "Error closing client socket", e);
        }
    }

    private byte[] buildConfirmationPacket(byte[] originalData) {
        // Simple confirmation packet (0x02 + last 2 bytes of original packet)
        if (originalData.length >= 2) {
            byte[] confirmation = new byte[3];
            confirmation[0] = 0x02;
            confirmation[1] = originalData[originalData.length - 2];
            confirmation[2] = originalData[originalData.length - 1];
            return confirmation;
        }
        return new byte[]{0x02, 0x00, 0x00};
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder result = new StringBuilder();
        for (byte b : bytes) {
            result.append(String.format("%02X", b));
        }
        return result.toString();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    getString(R.string.notification_channel_name),
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription(getString(R.string.notification_channel_description));
            
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
    }

    private Notification createNotification() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent,
                PendingIntent.FLAG_IMMUTABLE
        );

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle(getString(R.string.app_name))
                .setContentText(getString(R.string.server_running_notification))
                .setSmallIcon(R.drawable.ic_tracking)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build();
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "TCP Server Service destroying...");
        isRunning.set(false);
        
        // Close servers
        try {
            if (tcpServer != null) tcpServer.close();
            if (httpServer != null) httpServer.close();
        } catch (IOException e) {
            Log.e(TAG, "Error closing servers", e);
        }
        
        // Shutdown executor service
        executorService.shutdown();
        
        super.onDestroy();
    }

    // Public methods for other components
    public boolean isServerRunning() {
        return isRunning.get();
    }
    
    public int getConnectedDeviceCount() {
        return deviceConnections.size();
    }
    
    public ConcurrentHashMap<String, DeviceData> getDevices() {
        return devices;
    }
}
