function sanitize(str)
{
	return str
				.replace(/\\/g, "\\\\")
				.replace(/'/g, "\\'")
				.replace(/</g, "&lt;")
				.replace(/>/g, "&gt;");
}

