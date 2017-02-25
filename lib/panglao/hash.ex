defmodule Panglao.Hash do
  @env  Application.get_env(:panglao, :crypto)
  @aes  @env[:aes]
  @iv   @env[:iv]
  @salt @env[:salt]

  def encrypt(text, opts \\ []) do
    iv = if opts[:random], do: ExCrypto.rand_bytes!(16), else: @iv
    with {:ok, {_ad, {init_vec, cipher_text, cipher_tag}}} <- ExCrypto.encrypt(@aes, @salt, iv, "#{text}"),
         {:ok, encoded_payload} <- encode_payload(init_vec, cipher_text, cipher_tag) do
      encoded_payload
    end
  end

  def decrypt(text) do
    with {:ok, {init_vec, cipher_text, cipher_tag}} <- decode_payload("#{text}"),
         {:ok, clear_text} = ExCrypto.decrypt(@aes, @salt, init_vec, cipher_text, cipher_tag) do
      clear_text
    end
  end

  def encode_payload(initialization_vector, cipher_text, cipher_tag) do
    Base.encode16 initialization_vector <> cipher_text <> cipher_tag, case: :lower
  end

  def decode_payload(encoded_parts) do
    {:ok, decoded_parts} = Base.decode16 encoded_parts, case: :lower
    decoded_length = byte_size decoded_parts
    iv = Kernel.binary_part(decoded_parts, 0, 16)
    cipher_text = Kernel.binary_part decoded_parts, 16, (decoded_length - 32)
    cipher_tag = Kernel.binary_part decoded_parts, decoded_length, -16
    {:ok, {iv, cipher_text, cipher_tag}}
  end

  def short(text) do
    hash = encrypt text
    String.slice hash, 63, String.length(hash)
  end

  def randstring(len) do
    len
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, len)
  end

end
