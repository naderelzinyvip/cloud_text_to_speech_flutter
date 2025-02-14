import 'package:aws_common/aws_common.dart';
import 'package:cloud_text_to_speech/src/common/http/base_client.dart';
import 'package:http/http.dart' as http;
import 'package:aws_signature_v4/aws_signature_v4.dart';

import '../common/config.dart';

class AudioClientAmazon extends BaseClient {
  AudioClientAmazon({required http.Client client}) : super(client: client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Content-Type'] = "application/json";

    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(
        AWSCredentials(
          ConfigAmazon.keyId,
          ConfigAmazon.accessKey,
        ),
      ),
    );

    final signedRequest = await signer.sign(
      AWSHttpRequest(
        method: AWSHttpMethod.fromString(request.method),
        uri: request.url,
        headers: request.headers,
        body: request is http.Request ? request.bodyBytes : null,
      ),
      credentialScope: AWSCredentialScope(
        region: ConfigAmazon.region,
        service: const AWSService('polly'),
      ),
    );


    request.headers.addAll(signedRequest.headers);

    return client.send(request);
  }
}
