require 'json'
# This is a template for creating datasources in Jerakia (http://jerakia.io)
#
# In this simple example, we have a datasource that looks for a key in a series
# of JSON files formatted as;
#
# { "namespace": { "key": "value" } }
#
# The datasource should be declared as a subclass of Jerakia::Datasource that inherits
# the Jerakia::Datasource::Instance class
#
class Jerakia::Datasource::Example < Jerakia::Datasource::Instance

  # Options can be configured here by calling the option method, eg:
  #
  # option :files
  #
  # The option method supports arguments of :required and :default to
  # specify if the option is mandatory and optionally give it a default
  # value, eg:
  #
  # option :files, :required => true
  # option :files, :required => true, :default => [ '/etc/example/data.json' ]
  #
  # The option method can also be called with a code block to allow us to do some
  # extra validation on the value that the user configures, here we are going to
  # make the option :files mandatory and make sure that it is an array.

  option(:files, :required => true) { |opt|
    opt.is_a?(Array)
  }

  # A Jerakia datasource must support a lookup method, this method takes no arguments.
  # Here we can use the methods request, answer and options.  The options method returns
  # a hash of the user configured options, the request method returns the Jerakia::Request
  # object, the most useful things being request.key and request.namespace.  Finally the
  # answer method is used for the datasource to return it's answers.
  #

  def lookup
    
    # We're not going to add code to check for the existence of files because this is
    # just an example, so we'll keep it short.

    files = options[:files]

    # The request object has methods for returning the lookup key and namespace for this
    # request

    key = request.key
    namespace = request.namespace

    # The datasource does not need to be aware if this is a cascading lookup or not, that
    # is to say, whether or not we should continue through the hierarchy or stop at the first
    # result.  To return responses we call the answer method as a code block.  The answer
    # block will provide an iterator to accept one or many responses depending on the nature
    # of the lookup strategy.
    #
    # Here, for every iteration of answer we will take the next file from the :files array
    # and attempt to lookup and return the value, we do this until the answer iterator
    # finishes (Jerakia does not require further answers) or until we have nothing left to
    # search, in which case we just break from the block.
    #

    answer do |response|

      filename = files.shift


      # If filename is nil, there is nothing left to search, we break here and end
      break unless filename

      # Load in the JSON document
      data = JSON.load(File.read(filename))

      # If the value for the requested key exists in the namespace (see example JSON above)
      # then we return this data by calling the submit method of the response object in
      # this block

      if data.has_key(namespace)
        if data[namespace].has_key(key)
          response.submit data[namespace][key]
        end
      end

    end
  end
end
