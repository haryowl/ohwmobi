package com.ohw.parser.models;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

public class ParsedPacket {
    private String imei;
    private LocalDateTime timestamp;
    private double latitude;
    private double longitude;
    private double speed;
    private double direction;
    private int height;
    private int satellites;
    private double batteryVoltage;
    private double supplyVoltage;
    private int status;
    private Map<String, Object> additionalData;
    private String packetType;
    private int recordCount;

    public ParsedPacket() {
        this.additionalData = new HashMap<>();
        this.timestamp = LocalDateTime.now();
    }

    // Getters and Setters
    public String getImei() {
        return imei;
    }

    public void setImei(String imei) {
        this.imei = imei;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
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

    public double getDirection() {
        return direction;
    }

    public void setDirection(double direction) {
        this.direction = direction;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
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

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public Map<String, Object> getAdditionalData() {
        return additionalData;
    }

    public void setAdditionalData(Map<String, Object> additionalData) {
        this.additionalData = additionalData;
    }

    public String getPacketType() {
        return packetType;
    }

    public void setPacketType(String packetType) {
        this.packetType = packetType;
    }

    public int getRecordCount() {
        return recordCount;
    }

    public void setRecordCount(int recordCount) {
        this.recordCount = recordCount;
    }

    // Utility methods
    public void addAdditionalData(String key, Object value) {
        this.additionalData.put(key, value);
    }

    public Object getAdditionalData(String key) {
        return this.additionalData.get(key);
    }

    public boolean hasValidCoordinates() {
        return latitude != 0.0 || longitude != 0.0;
    }

    public boolean hasValidVoltage() {
        return batteryVoltage > 0 || supplyVoltage > 0;
    }

    public String getCoordinatesText() {
        if (hasValidCoordinates()) {
            return String.format("%.6f, %.6f", latitude, longitude);
        }
        return "No coordinates";
    }

    public String getSpeedText() {
        if (speed > 0) {
            return String.format("%.1f km/h", speed);
        }
        return "0 km/h";
    }

    public String getVoltageText() {
        if (hasValidVoltage()) {
            return String.format("Battery: %.1fV, Supply: %.1fV", batteryVoltage, supplyVoltage);
        }
        return "No voltage data";
    }

    @Override
    public String toString() {
        return "ParsedPacket{" +
                "imei='" + imei + '\'' +
                ", timestamp=" + timestamp +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", speed=" + speed +
                ", direction=" + direction +
                ", height=" + height +
                ", satellites=" + satellites +
                ", batteryVoltage=" + batteryVoltage +
                ", supplyVoltage=" + supplyVoltage +
                ", status=" + status +
                ", packetType='" + packetType + '\'' +
                ", recordCount=" + recordCount +
                ", additionalData=" + additionalData +
                '}';
    }
}
