using Godot;
using System;
using System.Diagnostics;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

public partial class PasswordCodeScene : Control
{
	private Label ErrorLabel;
	private LineEdit CodeInput;
	private string code = "";
	private string email = "";
	
	public override void _Ready()
	{
		ErrorLabel = GetNode<Label>("VBoxContainer/ErrorLabel");
		CodeInput = GetNode<LineEdit>("VBoxContainer/CodeInput");
		Node audioManager = GetNode("/root/AudioManager");
		Button button = GetNode<Button>("VBoxContainer/vefify button");
		button.Connect("pressed", new Callable(audioManager, "play_click"));
		button = GetNode<Button>("VBoxContainer/exit button");
		button.Connect("pressed", new Callable(audioManager, "play_click"));
		button = GetNode<Button>("VBoxContainer/send button");
		button.Connect("pressed", new Callable(audioManager, "play_click"));
	}
	
	private static string GeneratePassword(int length = 12)
	{
		const string lower = "abcdefghijklmnopqrstuvwxyz";
		const string upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		const string digits = "0123456789";
		const string special = "!@#$%^&*()-_=+[]{}|;:'\";,.<>?/";
		string allChars = lower + upper + digits + special;

		Random random = new Random();
		StringBuilder password = new StringBuilder();

		password.Append(lower[random.Next(lower.Length)]);
		password.Append(upper[random.Next(upper.Length)]);
		password.Append(digits[random.Next(digits.Length)]);
		password.Append(special[random.Next(special.Length)]);

		for (int i = 4; i < length; i++)
		{
			password.Append(allChars[random.Next(allChars.Length)]);
		}

		return new string(password.ToString().OrderBy(x => random.Next()).ToArray());
	}
	
	private static void SendEmail(string recipientEmail, string password)
	{
		return;
		try
		{
			var message = new MimeMessage();
			//message.From.Add(MailboxAddress.Parse(Environment.GetEnvironmentVariable("EMAIL_USERNAME")));
			message.From.Add(MailboxAddress.Parse("test.011001t@gmail.com"));
			message.To.Add(MailboxAddress.Parse(recipientEmail));
			message.Subject = "Slaptažodžio atkurimo kodas";

			message.Body = new TextPart("plain")
			{
				Text = $"Jūsų atkurimo kodas yra: {password}"
			};

			using (var client = new MailKit.Net.Smtp.SmtpClient())
			{
				client.CheckCertificateRevocation = false;
				//client.Connect(host: "smtp.gmail.com", port: 465, useSsl: true);
				client.Connect("smtp.gmail.com", 587, SecureSocketOptions.StartTls);
				client.Authenticate(
					//Environment.GetEnvironmentVariable("EMAIL_USERNAME"),
					//Environment.GetEnvironmentVariable("EMAIL_PASSWORD")
					"test.011001t@gmail.com",
					"ozji cykz zyii rgcm"
				);

				client.Send(message);
				client.Disconnect(true);
			}

			Console.WriteLine($"Password reset email sent to {recipientEmail}");
		}
		catch (Exception ex)
		{
			Debug.WriteLine($"Error sending email: {ex.Message}");
		}
	}
	
	public void set_email(string sent_email)
	{
		email = sent_email;
		code = GeneratePassword(20);
		Debug.WriteLine(code);
		SendEmail(email, code);
	}
	
	private void OnVerifyButtonPressed()
	{
		string text = CodeInput.Text;
		Debug.WriteLine("Entered Text: " + text);
		
		if(text == "")
		{
			ErrorLabel.Text = "Privaloma užpildyti kodo lauką.";
			return;
		}
		
		if(text != code)
		{
			ErrorLabel.Text = "Blogas kodas.";
			return;
		}
		
		Node sceneTransition = GetNode("/root/SceneTransition");
		sceneTransition.Call("new_node_with_call", 
					"res://scenes/password_reset_scenes/new_password_scene.tscn", "set_email", email);
	}
	
	private void OnSendButtonPressed()
	{
		code = GeneratePassword(20);
		Debug.WriteLine(code);
		SendEmail(email, code);
	}
	
	private void OnExitButtonPressed()
	{
		Node sceneTransition = GetNode("/root/SceneTransition");
		sceneTransition.Call("change_scene", 
									"res://scenes/password_reset_scenes/enter_email_scene.tscn");
	}
}
