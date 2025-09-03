package com.ohw.parser.parsers;

import android.util.Log;

import com.ohw.parser.models.ParsedPacket;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;

public class GalileoskyParser {
    
    private static final String TAG = "GalileoskyParser";
    
    // Packet types
    private static final byte PACKET_TYPE_DATA = 0x01;
    private static final byte PACKET_TYPE_CONFIRMATION = 0x02;
    private static final byte PACKET_TYPE_IGNORABLE = 0x15;
    
    // Tag types
    private static final byte TAG_IMEI = 0x03;
    private static final byte TAG_DEVICE_NUMBER = 0x04;
    private static final byte TAG_COMMAND_NUMBER = (byte) 0xE0;
    private static final byte TAG_COMMAND_TEXT = (byte) 0xE1;
    private static final byte TAG_ARCHIVE_RECORDS = 0x10;
    private static final byte TAG_DATETIME = 0x20;
    private static final byte TAG_MILLISECONDS = 0x21;
    private static final byte TAG_COORDINATES = 0x30;
    private static final byte TAG_SPEED_DIRECTION = 0x33;
    private static final byte TAG_HEIGHT = 0x34;
    private static final byte TAG_HDOP = 0x35;
    private static final byte TAG_STATUS = 0x40;
    private static final byte TAG_SUPPLY_VOLTAGE = 0x41;
    private static final byte TAG_BATTERY_VOLTAGE = 0x42;
    private static final byte TAG_INPUTS = 0x46;
    private static final byte TAG_INPUT_VOLTAGE_0 = 0x50;
    private static final byte TAG_INPUT_VOLTAGE_1 = 0x51;
    private static final byte TAG_USER_DATA_0 = (byte) 0xE2;
    private static final byte TAG_USER_DATA_1 = (byte) 0xE3;
    private static final byte TAG_USER_DATA_2 = (byte) 0xE4;
    private static final byte TAG_USER_DATA_3 = (byte) 0xE5;
    private static final byte TAG_USER_DATA_4 = (byte) 0xE6;
    private static final byte TAG_MODBUS_0 = 0x0001;

    public ParsedPacket parsePacket(byte[] data) {
        try {
            if (data == null || data.length < 3) {
                Log.w(TAG, "Packet too short: " + (data != null ? data.length : 0) + " bytes");
                return null;
            }

            byte header = data[0];
            Log.d(TAG, "Processing packet with header: 0x" + String.format("%02X", header));

            // Handle different packet types
            if (header == PACKET_TYPE_DATA) {
                return parseDataPacket(data);
            } else if (header == PACKET_TYPE_IGNORABLE) {
                Log.d(TAG, "Ignorable packet (0x15) - sending confirmation only");
                return null; // No data to parse, just send confirmation
            } else {
                Log.w(TAG, "Unknown packet type: 0x" + String.format("%02X", header));
                return null;
            }

        } catch (Exception e) {
            Log.e(TAG, "Error parsing packet", e);
            return null;
        }
    }

    private ParsedPacket parseDataPacket(byte[] data) {
        try {
            // Extract packet length (2 bytes, little endian)
            int rawLength = ByteBuffer.wrap(data, 1, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            boolean hasUnsentData = (rawLength & 0x8000) != 0;
            int actualLength = rawLength & 0x7FFF;
            
            Log.d(TAG, "Packet validation - Header: 0x01, Length: " + actualLength + 
                  ", HasUnsentData: " + hasUnsentData);

            // Check if we have the complete packet
            int expectedLength = actualLength + 3; // Header (1) + Length (2) + Data
            if (data.length < expectedLength + 2) { // +2 for CRC
                Log.w(TAG, "Incomplete packet: expected " + (expectedLength + 2) + 
                      " bytes, got " + data.length + " bytes");
                return null;
            }

            // For small packets (< 32 bytes), skip CRC validation
            if (actualLength < 32) {
                Log.d(TAG, "Small packet detected (" + actualLength + " bytes) - skipping CRC validation");
            } else {
                // Verify checksum for larger packets
                int calculatedChecksum = calculateCRC16(data, 0, expectedLength);
                int receivedChecksum = ByteBuffer.wrap(data, expectedLength, 2)
                    .order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
                
                Log.d(TAG, "CRC validation - Calculated: 0x" + 
                      String.format("%04X", calculatedChecksum) + 
                      ", Received: 0x" + String.format("%04X", receivedChecksum));
                
                if (calculatedChecksum != receivedChecksum) {
                    Log.w(TAG, "Checksum mismatch for packet with length " + actualLength);
                    return null;
                }
            }

            // Parse packet data
            return parsePacketData(data, 3, actualLength);

        } catch (Exception e) {
            Log.e(TAG, "Error parsing data packet", e);
            return null;
        }
    }

    private ParsedPacket parsePacketData(byte[] data, int offset, int length) {
        ParsedPacket packet = new ParsedPacket();
        packet.setPacketType("0x01");
        
        int currentOffset = offset;
        int endOffset = offset + length;
        
        Log.d(TAG, "Parsing packet data from offset " + offset + " to " + endOffset);

        while (currentOffset < endOffset) {
            if (currentOffset >= data.length) {
                Log.w(TAG, "Offset " + currentOffset + " exceeds data length " + data.length);
                break;
            }

            byte tag = data[currentOffset];
            currentOffset++;

            if (currentOffset >= data.length) {
                Log.w(TAG, "No data after tag 0x" + String.format("%02X", tag));
                break;
            }

            try {
                currentOffset = parseTag(data, currentOffset, tag, packet);
            } catch (Exception e) {
                Log.e(TAG, "Error parsing tag 0x" + String.format("%02X", tag), e);
                break;
            }
        }

        Log.d(TAG, "Packet parsed successfully");
        return packet;
    }

    private int parseTag(byte[] data, int offset, byte tag, ParsedPacket packet) {
        switch (tag) {
            case TAG_IMEI:
                return parseImeiTag(data, offset, packet);
            case TAG_DEVICE_NUMBER:
                return parseDeviceNumberTag(data, offset, packet);
            case TAG_ARCHIVE_RECORDS:
                return parseArchiveRecordsTag(data, offset, packet);
            case TAG_DATETIME:
                return parseDateTimeTag(data, offset, packet);
            case TAG_MILLISECONDS:
                return parseMillisecondsTag(data, offset, packet);
            case TAG_COORDINATES:
                return parseCoordinatesTag(data, offset, packet);
            case TAG_SPEED_DIRECTION:
                return parseSpeedDirectionTag(data, offset, packet);
            case TAG_HEIGHT:
                return parseHeightTag(data, offset, packet);
            case TAG_HDOP:
                return parseHdopTag(data, offset, packet);
            case TAG_STATUS:
                return parseStatusTag(data, offset, packet);
            case TAG_SUPPLY_VOLTAGE:
                return parseSupplyVoltageTag(data, offset, packet);
            case TAG_BATTERY_VOLTAGE:
                return parseBatteryVoltageTag(data, offset, packet);
            case TAG_INPUTS:
                return parseInputsTag(data, offset, packet);
            case TAG_INPUT_VOLTAGE_0:
                return parseInputVoltageTag(data, offset, 0, packet);
            case TAG_INPUT_VOLTAGE_1:
                return parseInputVoltageTag(data, offset, 1, packet);
            case TAG_USER_DATA_0:
            case TAG_USER_DATA_1:
            case TAG_USER_DATA_2:
            case TAG_USER_DATA_3:
            case TAG_USER_DATA_4:
                return parseUserDataTag(data, offset, tag, packet);
            default:
                Log.w(TAG, "Unknown tag: 0x" + String.format("%02X", tag));
                return offset + 1; // Skip unknown tag
        }
    }

    private int parseImeiTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 15 <= data.length) {
            String imei = new String(data, offset, 15).trim();
            packet.setImei(imei);
            Log.d(TAG, "Parsed IMEI: " + imei);
            return offset + 15;
        }
        return offset;
    }

    private int parseDeviceNumberTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int deviceNumber = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            packet.addAdditionalData("deviceNumber", deviceNumber);
            Log.d(TAG, "Parsed device number: " + deviceNumber);
            return offset + 2;
        }
        return offset;
    }

    private int parseArchiveRecordsTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int recordCount = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            packet.setRecordCount(recordCount);
            Log.d(TAG, "Parsed archive records: " + recordCount);
            return offset + 2;
        }
        return offset;
    }

    private int parseDateTimeTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 4 <= data.length) {
            int timestamp = ByteBuffer.wrap(data, offset, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
            LocalDateTime dateTime = LocalDateTime.ofEpochSecond(timestamp, 0, ZoneOffset.UTC);
            packet.setTimestamp(dateTime);
            Log.d(TAG, "Parsed datetime: " + dateTime);
            return offset + 4;
        }
        return offset;
    }

    private int parseMillisecondsTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int milliseconds = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            packet.addAdditionalData("milliseconds", milliseconds);
            Log.d(TAG, "Parsed milliseconds: " + milliseconds);
            return offset + 2;
        }
        return offset;
    }

    private int parseCoordinatesTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 8 <= data.length) {
            int latRaw = ByteBuffer.wrap(data, offset, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
            int lonRaw = ByteBuffer.wrap(data, offset + 4, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
            
            double latitude = latRaw / 1000000.0;
            double longitude = lonRaw / 1000000.0;
            
            packet.setLatitude(latitude);
            packet.setLongitude(longitude);
            
            Log.d(TAG, "Parsed coordinates: " + latitude + ", " + longitude);
            return offset + 8;
        }
        return offset;
    }

    private int parseSpeedDirectionTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 4 <= data.length) {
            int speedRaw = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            int directionRaw = ByteBuffer.wrap(data, offset + 2, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            
            double speed = speedRaw / 10.0; // Convert to km/h
            double direction = directionRaw / 10.0; // Convert to degrees
            
            packet.setSpeed(speed);
            packet.setDirection(direction);
            
            Log.d(TAG, "Parsed speed/direction: " + speed + " km/h, " + direction + "°");
            return offset + 4;
        }
        return offset;
    }

    private int parseHeightTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int height = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            packet.setHeight(height);
            Log.d(TAG, "Parsed height: " + height + " m");
            return offset + 2;
        }
        return offset;
    }

    private int parseHdopTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 1 <= data.length) {
            int hdop = data[offset] & 0xFF;
            packet.addAdditionalData("hdop", hdop);
            Log.d(TAG, "Parsed HDOP: " + hdop);
            return offset + 1;
        }
        return offset;
    }

    private int parseStatusTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int status = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            packet.setStatus(status);
            Log.d(TAG, "Parsed status: " + status);
            return offset + 2;
        }
        return offset;
    }

    private int parseSupplyVoltageTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int voltageRaw = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            double voltage = voltageRaw / 1000.0; // Convert to volts
            packet.setSupplyVoltage(voltage);
            Log.d(TAG, "Parsed supply voltage: " + voltage + "V");
            return offset + 2;
        }
        return offset;
    }

    private int parseBatteryVoltageTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int voltageRaw = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            double voltage = voltageRaw / 1000.0; // Convert to volts
            packet.setBatteryVoltage(voltage);
            Log.d(TAG, "Parsed battery voltage: " + voltage + "V");
            return offset + 2;
        }
        return offset;
    }

    private int parseInputsTag(byte[] data, int offset, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int inputsRaw = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            packet.addAdditionalData("inputs", inputsRaw);
            Log.d(TAG, "Parsed inputs: 0x" + String.format("%04X", inputsRaw));
            return offset + 2;
        }
        return offset;
    }

    private int parseInputVoltageTag(byte[] data, int offset, int inputNumber, ParsedPacket packet) {
        if (offset + 2 <= data.length) {
            int voltageRaw = ByteBuffer.wrap(data, offset, 2).order(ByteOrder.LITTLE_ENDIAN).getShort() & 0xFFFF;
            double voltage = voltageRaw / 1000.0; // Convert to volts
            packet.addAdditionalData("inputVoltage" + inputNumber, voltage);
            Log.d(TAG, "Parsed input voltage " + inputNumber + ": " + voltage + "V");
            return offset + 2;
        }
        return offset;
    }

    private int parseUserDataTag(byte[] data, int offset, byte tag, ParsedPacket packet) {
        if (offset + 4 <= data.length) {
            int userData = ByteBuffer.wrap(data, offset, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
            packet.addAdditionalData("userData" + (tag - 0xE2), userData);
            Log.d(TAG, "Parsed user data " + (tag - 0xE2) + ": " + userData);
            return offset + 4;
        }
        return offset;
    }

    private int calculateCRC16(byte[] data, int offset, int length) {
        int crc = 0xFFFF;
        for (int i = offset; i < offset + length; i++) {
            crc ^= data[i] & 0xFF;
            for (int j = 0; j < 8; j++) {
                if ((crc & 0x0001) != 0) {
                    crc = (crc >> 1) ^ 0xA001;
                } else {
                    crc = crc >> 1;
                }
            }
        }
        return crc;
    }
}
