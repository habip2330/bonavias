import React from 'react';

interface FormFieldProps {
  label: string;
  error?: string;
  required?: boolean;
  className?: string;
}

interface TextFieldProps extends FormFieldProps {
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url';
  value: string | number;
  onChange: (value: string) => void;
  placeholder?: string;
}

interface TextAreaProps extends FormFieldProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  rows?: number;
}

interface SelectFieldProps extends FormFieldProps {
  value: string;
  onChange: (value: string) => void;
  options: Array<{ value: string; label: string }>;
}

interface CheckboxProps extends Omit<FormFieldProps, 'required'> {
  checked: boolean;
  onChange: (checked: boolean) => void;
}

interface DateFieldProps extends FormFieldProps {
  value: string;
  onChange: (value: string) => void;
}

interface ImageUploadProps extends FormFieldProps {
  value?: string;
  onChange: (file: File) => void;
  preview?: string;
}

export const TextField: React.FC<TextFieldProps> = ({
  label,
  type = 'text',
  value,
  onChange,
  error,
  required,
  placeholder,
  className,
}) => (
  <div className={className}>
    <label className="block text-sm font-medium text-gray-700 mb-1">
      {label}
      {required && <span className="text-red-500 ml-1">*</span>}
    </label>
    <input
      type={type}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      required={required}
      className={`mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm h-10 px-3 ${
        error ? 'border-red-500' : ''
      }`}
    />
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

export const TextArea: React.FC<TextAreaProps> = ({
  label,
  value,
  onChange,
  error,
  required,
  placeholder,
  rows = 3,
  className,
}) => (
  <div className={className}>
    <label className="block text-sm font-medium text-gray-700 mb-1">
      {label}
      {required && <span className="text-red-500 ml-1">*</span>}
    </label>
    <textarea
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      required={required}
      rows={rows}
      className={`mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm p-3 min-h-[100px] ${
        error ? 'border-red-500' : ''
      }`}
    />
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

export const SelectField: React.FC<SelectFieldProps> = ({
  label,
  value,
  onChange,
  options,
  error,
  required,
  className,
}) => (
  <div className={className}>
    <label className="block text-sm font-medium text-gray-700 mb-1">
      {label}
      {required && <span className="text-red-500 ml-1">*</span>}
    </label>
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      required={required}
      className={`mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm h-10 px-3 ${
        error ? 'border-red-500' : ''
      }`}
    >
      <option value="">Select an option</option>
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

export const Checkbox: React.FC<CheckboxProps> = ({
  label,
  checked,
  onChange,
  error,
  className,
}) => (
  <div className={className}>
    <label className="flex items-center cursor-pointer">
      <div className="relative">
        <input
          type="checkbox"
          checked={checked}
          onChange={(e) => onChange(e.target.checked)}
          className="sr-only"
        />
        <div className={`block w-14 h-8 rounded-full transition-colors duration-300 ease-in-out ${
          checked ? 'bg-green-500' : 'bg-gray-300'
        }`} />
        <div className={`absolute left-1 top-1 bg-white w-6 h-6 rounded-full transition-transform duration-300 ease-in-out ${
          checked ? 'transform translate-x-6' : 'transform translate-x-0'
        }`} />
      </div>
      <span className="ml-3 text-sm text-gray-700">{label}</span>
    </label>
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

export const DateField: React.FC<DateFieldProps> = ({
  label,
  value,
  onChange,
  error,
  required,
  className,
}) => (
  <div className={className}>
    <label className="block text-sm font-medium text-gray-700 mb-1">
      {label}
      {required && <span className="text-red-500 ml-1">*</span>}
    </label>
    <input
      type="date"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      required={required}
      className={`mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm h-10 px-3 ${
        error ? 'border-red-500' : ''
      }`}
    />
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

export const ImageUpload: React.FC<ImageUploadProps> = ({
  label,
  onChange,
  error,
  required,
  preview,
  className,
}) => (
  <div className={className}>
    <label className="block text-sm font-medium text-gray-700 mb-1">
      {label}
      {required && <span className="text-red-500 ml-1">*</span>}
    </label>
    <div className="mt-1 flex flex-col items-center space-y-4">
      <div className="flex justify-center items-center w-full h-48 border-2 border-gray-300 border-dashed rounded-lg overflow-hidden bg-gray-50">
        {preview ? (
          <img src={preview} alt="Preview" className="w-full h-full object-contain" />
        ) : (
          <div className="text-center p-4">
            <svg
              className="mx-auto h-12 w-12 text-gray-400"
              stroke="currentColor"
              fill="none"
              viewBox="0 0 48 48"
              aria-hidden="true"
            >
              <path
                d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                strokeWidth={2}
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
            <p className="mt-2 text-sm text-gray-500">Click or drag to upload</p>
          </div>
        )}
      </div>
      <input
        type="file"
        accept="image/*"
        onChange={(e) => {
          const file = e.target.files?.[0];
          if (file) {
            onChange(file);
          }
        }}
        required={required}
        className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100"
      />
    </div>
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
); 