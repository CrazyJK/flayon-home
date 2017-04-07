package jk.kamoru.flayon.crazy;

import static org.junit.Assert.assertTrue;

import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;

import org.junit.Test;

import jk.kamoru.flayon.base.crypto.AES256;
import jk.kamoru.flayon.base.crypto.Crypto;
import jk.kamoru.flayon.base.crypto.RSA;
import jk.kamoru.flayon.base.crypto.SHA;
import jk.kamoru.flayon.base.crypto.Seed256;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CryptoTest {

	String plain = "0123456789 가나다라90-";

	@Test
	public void aes256ecb() {
		String key = "crazyjk-kamoru-58818";
		// ECB
		Crypto aes256 = new AES256(AES256.AlgorithmMode.ECB, key, null);
		String encrypt = aes256.encrypt(plain);
		log.info("aes256 ecb encrypt : " + encrypt);
		String decrypt = aes256.decrypt(encrypt);
		log.info("aes256 ecb decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}
	
	@Test
	public void aes256cbcNoIV() {
		String key = "crazyjk-kamoru-58818-6969";
		// CBC
		Crypto aes256 = new AES256(AES256.AlgorithmMode.CBC, key, null);
		String encrypt = aes256.encrypt(plain);
		log.info("aes256 cbc no iv encrypt : " + encrypt);
		String decrypt = aes256.decrypt(encrypt);
		log.info("aes256 cbc no iv decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}

	@Test
	public void aes256cbcWithIV() {
		String key = "handysoft csd-next";
		String iv = "csrnd";
		// CBC
		Crypto aes256 = new AES256(AES256.AlgorithmMode.CBC, key, iv);
		String encrypt = aes256.encrypt(plain);
		log.info("aes256 cbc with iv encrypt : " + encrypt);
		String decrypt = aes256.decrypt(encrypt);
		log.info("aes256 cbc with iv decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}

	@Test
	public void rsa() {
		KeyPair keyPair = RSA.generateKey();
		
		String publicKeyString = RSA.getKeyString(keyPair.getPublic());
		PublicKey publicKey = RSA.getPublicKey(publicKeyString);

		String privateKeyString = RSA.getKeyString(keyPair.getPrivate());
		PrivateKey privateKey = RSA.getPrivateKey(privateKeyString);
		
		log.info("rsa public  key : " + publicKeyString);
		log.info("rsa pirvate key : " + privateKeyString);
		
		Crypto rsa = new RSA(publicKey, privateKey);
		
		String encrypt = rsa.encrypt(plain);
		log.info("rsa encrypt : " + encrypt);
		
		String decrypt = rsa.decrypt(encrypt);
		log.info("rsa decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}

	@Test
	public void sha1() {
		Crypto sha1 = new SHA(SHA.AlgorithmType.SHA1);
		log.info("sha1   encrypt : " + sha1.encrypt(plain));
	}
	@Test
	public void sha256() {
		Crypto sha256 = new SHA(SHA.AlgorithmType.SHA256);
		log.info("sha256 encrypt : " + sha256.encrypt(plain));
	}
	@Test
	public void sha384() {
		Crypto sha384 = new SHA(SHA.AlgorithmType.SHA384);
		log.info("sha384 encrypt : " + sha384.encrypt(plain));
	}
	@Test
	public void sha512() {
		Crypto sha512 = new SHA(SHA.AlgorithmType.SHA512);
		log.info("sha512 encrypt : " + sha512.encrypt(plain));		
	}
	
	@Test
	public void seed256() {
		Crypto seed256 = new Seed256();
		
		String encrypt = seed256.encrypt(plain);
		log.info("seed256 encrypt : " + encrypt);
		
		String decrypt = seed256.decrypt(encrypt);
		log.info("seed256 decrypt : " + decrypt);

		assertTrue(plain.equals(decrypt));
	}
}
