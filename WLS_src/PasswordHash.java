import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class PasswordHash {
    
    private static final String ALGORITHM = "SHA-256";
    private static final int SALT_LENGTH = 32;
    
    /**
     * Hash a password with a random salt.
     * The returned string contains both the salt and hash (Base64 encoded).
     * Each call produces a DIFFERENT hash for the same password (random salt).
     */
    public static String hashPassword(String password) {
        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[SALT_LENGTH];
            random.nextBytes(salt);
            
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes(StandardCharsets.UTF_8));
            
            byte[] combined = new byte[salt.length + hashedPassword.length];
            System.arraycopy(salt, 0, combined, 0, salt.length);
            System.arraycopy(hashedPassword, 0, combined, salt.length, hashedPassword.length);
            
            return Base64.getEncoder().encodeToString(combined);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Hashing algorithm not found", e);
        }
    }
    
    /**
     * Verify a plaintext password against a stored hash.
     * Extracts the salt from the stored hash, re-hashes the input,
     * and compares in constant time.
     */
    public static boolean verifyPassword(String password, String storedHash) {
        try {
            byte[] combined = Base64.getDecoder().decode(storedHash);
            
            byte[] salt = new byte[SALT_LENGTH];
            System.arraycopy(combined, 0, salt, 0, SALT_LENGTH);
            
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes(StandardCharsets.UTF_8));
            
            byte[] storedHashedPassword = new byte[combined.length - SALT_LENGTH];
            System.arraycopy(combined, SALT_LENGTH, storedHashedPassword, 0, storedHashedPassword.length);
            
            return MessageDigest.isEqual(hashedPassword, storedHashedPassword);
        } catch (NoSuchAlgorithmException | IllegalArgumentException e) {
            return false;
        }
    }
}
