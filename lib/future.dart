import 'dart:async';

void main() {
	print('Program starts.');
	printFileCOntent();
	print('Program ends.');
}

printFileCOntent() async {
	String value = await downloadText();
	print('The value is --> $value');
}

Future<String> downloadText() {
	Future<String> content = Future.delayed(Duration(seconds: 6), (){
		return 'My secret file content';
	});

	return content;
}