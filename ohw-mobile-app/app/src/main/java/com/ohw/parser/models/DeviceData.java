package com.ohw.parser.models;

import java.net.SocketAddress;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

public class DeviceData {
    private String imei;
    private String clientAddress;
    private LocalDateTime lastSeen;
    private int totalRecords;
    private boolean isOnline;
    private double latitude;
    private double longitude;
    private double speed;
    private int satellites;
    private double batteryVoltage;
    private double supplyVoltage;

    public DeviceData(String imei) {
        this.imei = imei;
        this.lastSeen = LocalDateTime.now();
        this.totalRecords = 0;
        this.isOnline = false;
    }

    // Getters and Setters
    public String getImei() {
        return imei;
    }

    public void setImei(String imei) {
        this.imei = imei;
    }

    public String getClientAddress() {
        return clientAddress;
    }

    public void setClientAddress(String clientAddress) {
        this.clientAddress = clientAddress;
    }

    public LocalDateTime getLastSeen() {
        return lastSeen;
    }

    public void setLastSeen(LocalDateTime lastSeen) {
        this.lastSeen = lastSeen;
    }

    public int getTotalRecords() {
        return totalRecords;
    }

    public void setTotalRecords(int totalRecords) {
        this.totalRecords = totalRecords;
    }

    public boolean isOnline() {
        return isOnline;
    }

    public void setOnline(boolean online) {
        isOnline = online;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getSpeed() {
        return speed;
    }

    public void setSpeed(double speed) {
        this.speed = speed;
    }

    public int getSatellites() {
        return satellites;
    }

    public void setSatellites(int satellites) {
        this.satellites = satellites;
    }

    public double getBatteryVoltage() {
        return batteryVoltage;
    }

    public void setBatteryVoltage(double batteryVoltage) {
        this.batteryVoltage = batteryVoltage;
    }

    public double getSupplyVoltage() {
        return supplyVoltage;
    }

    public void setSupplyVoltage(double supplyVoltage) {
        this.supplyVoltage = supplyVoltage;
    }

    // Utility methods
    public void updateLastSeen() {
        this.lastSeen = LocalDateTime.now();
    }

    public void incrementRecordCount() {
        this.totalRecords++;
    }

    public void updateLocation(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public void updateStatus(boolean online) {
        this.isOnline = online;
        if (online) {
            updateLastSeen();
        }
    }

    public String getStatusText() {
        if (isOnline) {
            return "Online";
        } else {
            return "Offline";
        }
    }

    public String getLastSeenText() {
        if (lastSeen != null) {
            return lastSeen.toString();
        }
        return "Never";
    }

    @Override
    public String toString() {
        return "DeviceData{" +
                "imei='" + imei + '\'' +
                ", clientAddress='" + clientAddress + '\'' +
                ", lastSeen=" + lastSeen +
                ", totalRecords=" + totalRecords +
                ", isOnline=" + isOnline +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", speed=" + speed +
                ", satellites=" + satellites +
                ", batteryVoltage=" + batteryVoltage +
                ", supplyVoltage=" + supplyVoltage +
                '}';
    }
}
