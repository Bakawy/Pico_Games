import { DiscordSDK } from "./discord-sdk.js";
	try {
		const discordSdk = new DiscordSDK("1568863112751222905");
		await discordSdk.ready();
		console.log(`Discord connected: channel ${discordSdk.channelId}, instance ${discordSdk.instanceId}`);
	} catch (err) {
		console.error("Discord SDK failed:", err); // game still runs outside Discord
	}
