import React from 'react';
import { shallow } from 'enzyme';
import renderer from 'react-test-renderer';

import About from '../About';

test('About renders properly', () => {
  const wrapper = shallow(<About/>);
  const element = wrapper.find('p');
  expect(element.length).toBe(1);
  expect(element.text()).toBe('View the source code for this application on Github');
});

test('About renders a snapshot properly', () => {
  const tree = renderer.create(<About/>).toJSON();
  expect(tree).toMatchSnapshot();
});
