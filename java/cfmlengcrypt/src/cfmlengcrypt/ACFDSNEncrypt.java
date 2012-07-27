package cfmlengcrypt;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;

import org.apache.commons.ssl.OpenSSL;

/**
 * Encrypts CFDSN passwords
 */
public class ACFDSNEncrypt {

	public static void main(String[] args) {
		encrypt(args[0]);
	}

	public static void encrypt(String plaintext) {
		byte[] key = "30794A21403124723870304C4072312436794A214031726A".getBytes();
		byte[] iv = "30794A2140312472".getBytes();
		byte[] data;
		try {
			byte[] encryptedData = OpenSSL.encrypt("des3-ede3", key, iv, plaintext.getBytes());
			String encryptedString = new String(encryptedData, "UTF-8");
			System.out.print(encryptedString);
			encryptedData = encryptedString.getBytes("UTF-8");
			data = OpenSSL.decrypt("des3-ede3", key, iv, encryptedData);
			//System.out.println("DECRYPTED: [" + new String(data) + "]");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		catch (IOException e) {
			e.printStackTrace();
		} catch (GeneralSecurityException e) {
			e.printStackTrace();
		}
	}
	
}